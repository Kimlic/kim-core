defmodule Quorum.Contract.KimlicContractsContext do
  @moduledoc """
  KimlicContractsContext with generated functions via macros
  """

  use Quorum.Contract, :kimlic_contracts_context

  eth_call("getAccountStorageAdapter", [])
  eth_call("getVerificationContractFactory", [])
end
