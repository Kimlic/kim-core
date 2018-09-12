defmodule Core.Sync do
  @moduledoc """
  Returns verification fields that were previously set with their data
  """

  alias Quorum.ABI.TypeDecoder
  alias Quorum.Contract.AccountStorageAdapter
  alias Quorum.Contract.Context

  @quorum_client Application.get_env(:quorum, :client)

  @doc """
  Run sync proccess:
  - Validates account fields exist and set
  - Receives field details
  - Formats response data
  """
  @spec handle(binary) :: [map]
  def handle(account_address) do
    unlock_profile_sync_user()
    account_storage_adapter_address = Context.get_account_storage_adapter_address()

    :core
    |> Application.get_env(:core, :sync_fields)
    |> Enum.filter(
      &Kernel.==(
        Quorum.validate_account_field_exists_and_set(account_address, &1, account_storage_adapter_address),
        :ok
      )
    )
    |> Enum.reduce([], fn sync_field, acc ->
      with {:ok, {field_value, verification_status, verification_contract_address, verified_on}} <-
             get_field_details(account_address, sync_field, account_storage_adapter_address) do
        verification_contract_address = "0x" <> Base.encode16(verification_contract_address, case: :lower)

        [
          %{
            "name" => sync_field,
            "value" => field_value,
            "status" => verification_status,
            "verification_contract" => verification_contract_address,
            "verified_on" => to_timestamp(verified_on)
          }
        ] ++ acc
      else
        _ -> acc
      end
    end)
    |> Enum.reverse()
  end

  @spec unlock_profile_sync_user :: {:ok, binary} | {:error, binary}
  defp unlock_profile_sync_user do
    profile_sync_user_address = Application.get_env(:quorum, :profile_sync_user_address)
    profile_sync_user_password = Application.get_env(:quorum, :profile_sync_user_password)

    @quorum_client.request("personal_unlockAccount", [profile_sync_user_address, profile_sync_user_password], [])
  end

  @spec get_field_details(binary, binary, binary) :: {:ok, tuple} | {:error, binary}
  defp get_field_details(account_address, sync_field, account_storage_addapter_address) do
    types = [{:tuple, [:string, :string, :address, {:uint, 256}]}]

    field_details =
      AccountStorageAdapter.get_field_details(account_address, sync_field, %{
        from: Application.get_env(:quorum, :profile_sync_user_address),
        to: account_storage_addapter_address
      })

    with {_, {:ok, "0x" <> field_details_response}} <- {:quorum_error, field_details},
         _ <- Log.info("#{__MODULE__} get_field_details: #{inspect(field_details_response)}"),
         true <- field_details_response != "",
         [{_sha256, _status, _contract_address, _verified_on} = fields] <-
           field_details_response
           |> Base.decode16!(case: :lower)
           |> TypeDecoder.decode_raw(types) do
      {:ok, fields}
    else
      {:quorum_error, err} ->
        Log.error("[#{__MODULE__}]: Fail to sync with error: #{inspect(err)}")
        {:error, "Fail to sync"}

      _ ->
        {:error, "Fail to sync"}
    end
  end

  @spec to_timestamp(integer) :: integer
  defp to_timestamp(timestamp), do: round(timestamp / 1_000_000_000)
end
