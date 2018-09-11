defmodule Quorum.Contract.VerificationContractFactory do
  @moduledoc """
  VerificationContractFactory with generated functions via macros
  """

  use Quorum.Contract, :verification_contract_factory

  eth_call("getVerificationContract", [key])
  call_function("createBaseVerificationContract", [account, attestation_party_address, key, account_field_name])
end
