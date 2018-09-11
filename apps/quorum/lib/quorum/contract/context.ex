defmodule Quorum.Contract.Context do
  @moduledoc """
  Module that fetch contract adresses from KimlicContractContext contract
  """

  alias Quorum.Contract.{KimlicContextStorage, KimlicContractsContext}

  @doc """
  Returns attestation party address
  """
  @spec get_kimlic_attestation_party_address :: binary
  def get_kimlic_attestation_party_address do
    Confex.fetch_env!(:quorum, :kimlic_ap_address)
  end

  @doc """
  Returns context address
  """
  @spec get_context_address :: binary
  def get_context_address do
    context_storage_address = Confex.fetch_env!(:quorum, :context_storage_address)
    {:ok, address} = KimlicContextStorage.get_context(%{to: context_storage_address})

    address64_to_40(address)
  end

  @doc """
  Returns account storage adapter address
  """
  @spec get_account_storage_adapter_address :: binary
  def get_account_storage_adapter_address do
    {:ok, address} = KimlicContractsContext.get_account_storage_adapter(%{to: get_context_address()})

    address64_to_40(address)
  end

  @doc """
  Returns verification contract factory address
  """
  @spec get_verification_contract_factory_address :: binary
  def get_verification_contract_factory_address do
    {:ok, address} = KimlicContractsContext.get_verification_contract_factory(%{to: get_context_address()})

    address64_to_40(address)
  end

  @doc """
  Convert 32 bytes address to 20 bytes address
  """
  @spec address64_to_40(binary) :: binary
  def address64_to_40(address), do: String.replace(address, String.duplicate("0", 24), "")
end
