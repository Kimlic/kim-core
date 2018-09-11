defmodule Quorum.Unit.ContractTest do
  @moduledoc false

  use ExUnit.Case
  import Mox
  alias Quorum.Contract

  test "call_function" do
    assert :ok = Contract.call_function(:base_verification, "finalizeVerification", [{true}])
  end

  test "eth_call" do
    account_address = "0x222134db3538b791c96a4185308803ffbdb7760z"
    expect(QuorumClientMock, :eth_call, fn _data, _, _ -> {:ok, account_address} end)

    assert {:ok, ^account_address} = Contract.eth_call(:kimlic_context_storage, "getContext", [])
  end
end
