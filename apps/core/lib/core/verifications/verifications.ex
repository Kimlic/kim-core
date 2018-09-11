defmodule Core.Verifications do
  @moduledoc """
  Defines business logic and DB operations with Verification entity
  """

  import Core.Verifications.Verification, only: [allowed_type_atom: 1]

  alias __MODULE__
  alias Core.Clients.Redis
  alias Core.Email
  alias Core.Verifications.Verification
  alias Log

  @typep create_verification_t :: {:ok, %Verification{}} | {:error, binary} | {:error, Ecto.Changeset.t()}

  @messenger Application.get_env(:core, :dependencies)[:messenger]

  ### Business

  @doc """
  Creates email verification and verification contract
  """
  @spec create_email_verification(binary, binary) :: create_verification_t
  def create_email_verification(email, account_address) do
    with {:ok, verification} <- create_verification(account_address, :email),
         :ok <- create_verification_contract(:email, account_address, email) do
      {:ok, verification}
    else
      {:error, :account_field_not_set} ->
        {:error, {:conflict, "Account.email not set via AccountStorageAdapter.setFieldMainData"}}

      {:error, :account_field_has_verification} ->
        {:error, {:conflict, "There is already a verification contract for this email"}}

      err ->
        err
    end
  end

  @doc """
  Creates phone verification and verification contract
  """
  @spec create_phone_verification(binary, binary) :: create_verification_t
  def create_phone_verification(phone, account_address) do
    with {:ok, %Verification{} = verification} <- create_verification(account_address, :phone),
         :ok <- create_verification_contract(:phone, account_address, phone) do
      {:ok, verification}
    else
      {:error, :account_field_not_set} ->
        {:error, {:conflict, "Account.phone not set via AccountStorageAdapter.setFieldMainData"}}

      {:error, :account_field_has_verification} ->
        {:error, {:conflict, "There is already a verification contract for this phone number"}}

      err ->
        err
    end
  end

  @doc """
  Creates and inserts verification to database
  """
  @spec create_verification(binary, atom) :: create_verification_t
  def create_verification(account_address, type) when allowed_type_atom(type) do
    %{
      account_address: account_address,
      token: generate_token(type),
      entity_type: Verification.entity_type(type),
      status: Verification.status(:new)
    }
    |> insert_verification(verification_ttl(type))
  end

  @doc """
  Generates token for verificaiton
  """
  @spec generate_token(:email | :phone) :: binary
  def generate_token(:phone), do: "#{Enum.random(1000..9999)}"
  def generate_token(:email), do: "#{Enum.random(1000..9999)}"

  @spec create_verification_contract(atom, binary, binary) :: :ok
  defp create_verification_contract(type, account_address, destination) do
    Quorum.create_verification_contract(
      type,
      account_address,
      {__MODULE__, :update_verification_contract_address, [account_address, type, destination]}
    )
  end

  @doc """
  Verifies verification with next steps:
  - Receives it from database
  - Checks access
  - Sets verification result in Qourum
  - Removes verification
  """
  @spec verify(atom, binary, binary) :: :ok | {:error, term}
  def verify(verification_type, account_address, token) when allowed_type_atom(verification_type) do
    with {:ok, %Verification{} = verification} <- Verifications.get(verification_type, account_address),
         {_, "0x" <> _} <- {:contract_address_set, verification.contract_address},
         {_, true} <- {:verification_access, can_access_verification?(verification, account_address, token)},
         :ok <- Quorum.set_verification_result_transaction(verification.contract_address),
         {:ok, 1} <- Verifications.delete(verification) do
      :ok
    else
      {:contract_address_set, _} -> {:error, {:conflict, "Verification.contract_address not set yet. Try later"}}
      {:verification_access, _} -> {:error, {:not_found, "Verification not found. Invalid account address or code"}}
      {:error, :not_found} -> {:error, {:not_found, "Verification not found"}}
      err -> err
    end
  end

  @spec can_access_verification?(%Verification{}, binary, binary) :: boolean
  defp can_access_verification?(
         %{token: token, account_address: account_address},
         request_account_address,
         request_token
       ) do
    account_address == request_account_address and token == request_token
  end

  @spec verification_ttl(atom) :: pos_integer
  defp verification_ttl(:phone), do: Confex.fetch_env!(:core, :verifications_ttl)[:phone]
  defp verification_ttl(:email), do: Confex.fetch_env!(:core, :verifications_ttl)[:email]

  ### Callbacks (do not remove)

  @doc """
  Updates verification contract address, sends email or sms depending on verification
  """
  @spec update_verification_contract_address(binary, binary, binary, map, {:ok, binary} | {:error, binary}) :: term
  def update_verification_contract_address(
        account_address,
        verification_type,
        destination,
        _transaction_status,
        {:ok, contract_address}
      ) do
    # Callback data is serialized when passed to rabbitmq, so `verification_type` becomes string instead of atom

    verification_type = String.to_atom(verification_type)
    update_data = %{contract_address: contract_address}

    with {:ok, verification} = Verifications.get(verification_type, account_address),
         {:ok, _} <- Redis.update(verification, update_data, verification_ttl(verification_type)) do
      case verification_type do
        :email -> Email.send_verification(destination, verification.token)
        :phone -> @messenger.send(destination, "Here is your code: #{verification.token}")
      end
    end

    :ok
  end

  def update_verification_contract_address(_, _, _, _, {:error, reason}) do
    Log.error("[#{__MODULE__}]: fail to update verification contract address with info: #{inspect(reason)}")
  end

  ### CRUD

  @spec insert_verification(map, binary) :: create_verification_t
  defp insert_verification(attrs, verification_ttl) do
    with %Ecto.Changeset{valid?: true} = verification <- Verification.changeset(attrs) do
      Redis.upsert(verification, verification_ttl)
    end
  end

  @doc """
  Finds verification by entity_type and user account address
  """
  @spec get(binary, atom) :: {:ok, %Verification{}} | {:error, term}
  def get(type, account_address) do
    type
    |> Verification.redis_key(account_address)
    |> Redis.get()
  end

  @doc """
  Removes verification
  """
  @spec delete(%Verification{} | term) :: {:ok, non_neg_integer} | {:error, term}
  def delete(%Verification{} = verification), do: Redis.delete(verification)
end
