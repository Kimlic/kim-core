defmodule Quorum do
  @moduledoc """
  Quorum client.
  Creates transaction and check transaction status.
  Works in 2 RabbitMQ queues: transaction_create and transaction_status.
  """

  alias Quorum.Contract.AccountStorageAdapter
  alias Quorum.Contract.BaseVerification
  alias Quorum.Contract.Context
  alias Quorum.Contract.VerificationContractFactory
  alias Quorum.Jobs.TransactionCreate

  @type callback :: nil | {module :: module, function :: atom, args :: list}
  @type quorum_client_response_t :: {:ok, term} | {:error, map | binary | atom}

  @quorum_client Application.get_env(:quorum, :client)

  @gas_price "0x0"
  @hashed_false "0x0000000000000000000000000000000000000000000000000000000000000000"

  defguardp is_callback(mfa)
            when is_tuple(mfa) and tuple_size(mfa) == 3 and
                   (is_atom(elem(mfa, 0)) and is_atom(elem(mfa, 1)) and is_list(elem(mfa, 2)))

  @spec create_verification_contract(atom, binary, callback) :: :ok | {:error, map}
  def create_verification_contract(type, account_address, callback) do
    verification_field = Atom.to_string(type)
    account_storage_adapter_address = Context.get_account_storage_adapter_address()

    Log.info(
      "[#{__MODULE__}]#create_verification_contract data: " <>
        "account_address: #{account_address}, verification_field: #{verification_field}"
    )

    with :ok <-
           validate_account_field_exists_and_set(account_address, verification_field, account_storage_adapter_address),
         :ok <-
           validate_account_field_has_no_verification(
             account_address,
             verification_field,
             account_storage_adapter_address
           ) do
      create_verification_transaction(account_address, verification_field, callback)
    end
  end

  @spec validate_account_field_exists_and_set(binary, binary, binary) :: :ok | {:error, atom}
  def validate_account_field_exists_and_set(account_address, field, to) do
    result = AccountStorageAdapter.get_field_history_length(account_address, field, %{to: to})

    Log.info("[#{__MODULE__}] validate_account_field_exists_and_set: #{inspect(result)}")

    case result do
      {:ok, @hashed_false} ->
        {:error, :account_field_not_set}

      # byte_size 66 = hex prefix `0x` + 32 bytes
      {:ok, resp} when byte_size(resp) != 66 ->
        {:error, :account_field_not_set}

      {:ok, _} ->
        :ok

      err ->
        err
    end
  end

  @spec validate_account_field_has_no_verification(binary, binary, binary) :: :ok | {:error, atom}
  defp validate_account_field_has_no_verification(account_address, field, to) do
    {:ok, profile_sync_user_address} = unlock_profile_sync_user()

    result =
      AccountStorageAdapter.get_last_field_verification_contract_address(account_address, field, %{
        to: to,
        from: profile_sync_user_address
      })

    Log.info("[#{__MODULE__}] validate_account_field_has_no_verification: #{inspect(result)}")

    case result do
      {:ok, @hashed_false} ->
        :ok

      {:ok, contract_address} ->
        validate_verification_contract_expired(contract_address, profile_sync_user_address)

      err ->
        Log.error("[#{__MODULE__}] Fail to call get_last_field_verification_contract_address #{inspect(err)}")
        err
    end
  end

  @spec validate_verification_contract_expired(binary, binary) :: :ok | {:error, atom}
  defp validate_verification_contract_expired(contract_address, profile_sync_user_address) do
    {:ok, time} = BaseVerification.tokens_unlock_at(%{from: profile_sync_user_address, to: contract_address})

    case :os.system_time(:second) > time do
      true ->
        BaseVerification.withdraw(%{from: profile_sync_user_address, to: contract_address})
        :ok

      false ->
        {:error, :account_field_has_verification}
    end
  end

  @spec unlock_profile_sync_user :: {:ok, binary}
  defp unlock_profile_sync_user do
    address = Confex.fetch_env!(:quorum, :profile_sync_user_address)
    password = Confex.fetch_env!(:quorum, :profile_sync_user_password)

    {:ok, _} = @quorum_client.request("personal_unlockAccount", [address, password], [])
    {:ok, address}
  end

  @spec create_verification_transaction(binary, binary, callback) :: :ok
  defp create_verification_transaction(account_address, verification_field, callback) when is_callback(callback) do
    return_key = UUID.uuid4()
    kimlic_ap_address = Context.get_kimlic_attestation_party_address()
    kimlic_ap_password = Confex.fetch_env!(:quorum, :kimlic_ap_password)
    verification_contract_factory_address = Context.get_verification_contract_factory_address()

    meta = %{
      callback: callback,
      verification_contract_return_key: return_key,
      verification_contract_factory_address: verification_contract_factory_address
    }

    @quorum_client.request("personal_unlockAccount", [kimlic_ap_address, kimlic_ap_password], [])

    VerificationContractFactory.create_base_verification_contract(
      account_address,
      kimlic_ap_address,
      return_key,
      verification_field,
      %{
        from: kimlic_ap_address,
        to: verification_contract_factory_address,
        meta: meta
      }
    )
  end

  @spec set_verification_result_transaction(binary) :: :ok
  def set_verification_result_transaction(contract_address) do
    kimlic_ap_address = Context.get_kimlic_attestation_party_address()
    kimlic_ap_password = Confex.fetch_env!(:quorum, :kimlic_ap_password)

    @quorum_client.request("personal_unlockAccount", [kimlic_ap_address, kimlic_ap_password], [])

    BaseVerification.finalize_verification(true, %{from: kimlic_ap_address, to: contract_address})
  end

  @spec set_digital_verification_result_transaction(binary, boolean) :: :ok
  def set_digital_verification_result_transaction(contract_address, status) when is_boolean(status) do
    veriff_ap_address = Confex.fetch_env!(:quorum, :veriff_ap_address)
    veriff_ap_password = Confex.fetch_env!(:quorum, :veriff_ap_password)

    @quorum_client.request("personal_unlockAccount", [veriff_ap_address, veriff_ap_password], [])

    BaseVerification.finalize_verification(status, %{from: veriff_ap_address, to: contract_address})
  end

  @doc """
    Create transaction in Quorum via TaskBunny.
    Uses two jobs `TransactionCreate` and `TransactionStatus` that applied to two queues respectively:
    `transaction` and `transaction_status`.

    `TransactionCreate`
    Steps:
      1. creates transaction in Quorum using `eth_sendTransaction` call
      2. on success response from Quorum - create second job `TransactionStatus` with transaction hash

    `TransactionStatus`
    Steps:
      1. Check transaction status in Quorum using `eth_get_transaction_receipt` call
      2. Try 5 times, until success responce. On failed response - mark job as failed
      3. If argument `provide_return_value` set as true: fetch `return_value` from Quorum using `debug_traceTransaction` call
      4. Call callback if it provided. Transaction status and return value will be added as last arguments.
         Transaction status argument - @type :: map
         Retrun value argument - @type :: {:ok, binary} | {:error, binary}

    ## Examples

      create_transaction(%{...}, {MyModule, :callback, ["my_callback_param"]})

      def MyModule do

        def callback("my_callback_param", transaction_status, {:ok, return_value}), do: ...

        def callback("my_callback_param", transaction_status, {:error, reason}), do: ...
      end

  """
  @spec create_transaction(map, map) :: :ok
  def create_transaction(transaction_data, meta \\ %{}) do
    TransactionCreate.enqueue!(%{
      meta: prepare_callback(meta),
      transaction_data: put_gas(transaction_data)
    })
  end

  @spec put_gas(map) :: map
  defp put_gas(transaction_data), do: Map.merge(%{gasPrice: @gas_price, gas: gas()}, transaction_data)

  defp prepare_callback(%{callback: {module, function, args}} = meta),
    do: Map.put(meta, :callback, %{m: module, f: function, a: args})

  defp prepare_callback(%{callback: callback}) do
    raise "Invalid callback format. Requires: {module, function, args} tuple, get: #{inspect(callback)}}"
  end

  defp prepare_callback(meta), do: meta

  @spec gas :: binary
  def gas, do: Confex.fetch_env!(:quorum, :gas)
end
