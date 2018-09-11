defmodule Quorum.Contract.AccountStorageAdapter do
  @moduledoc """
  AccountStorageAdapter with generated functions via macros
  """

  use Quorum.Contract, :account_storage_adapter

  eth_call("getFieldDetails", [account_address, account_field_name])
  eth_call("getFieldHistoryLength", [account_address, account_field_name])
  eth_call("getLastFieldVerificationContractAddress", [account_address, account_field_name])
end
