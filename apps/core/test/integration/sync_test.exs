defmodule Core.Integration.SyncTest do
  @moduledoc false

  use ExUnit.Case, async: false

  alias Core.Sync
  alias Quorum.Contract
  alias Quorum.Contract.Context

  @moduletag :integration

  @quorum_client Application.get_env(:quorum, :client)

  @empty_address "0x0000000000000000000000000000000000000000"

  @tag :pending
  test "sync data success" do
    {:ok, account_address} = @quorum_client.request("personal_newAccount", ["p@ssW0rd"], [])
    {:ok, _} = @quorum_client.request("personal_unlockAccount", [account_address, "p@ssW0rd"], [])

    for field <- ["email", "phone", "documents.id_card"],
        do: set_field_data(field, account_address, Context.get_account_storage_adapter_address())

    for field <- ["email", "phone"],
        do: add_verification(field, account_address)

    assert [email_verification, phone_verification, document_verification] = Sync.handle(account_address)
    assert_verified("email", email_verification)
    assert_verified("phone", phone_verification)

    assert %{"name" => "documents.id_card", "status" => "", "verification_contract" => @empty_address} =
             document_verification
  end

  defp assert_verified(field, verification) do
    assert %{"name" => ^field, "status" => "Verified"} = verification
    assert verification["verification_contract"] != @empty_address
  end

  defp set_field_data(field, account_address, account_storage_adapter_address) do
    transaction_data = %{
      from: account_address,
      to: account_storage_adapter_address,
      data:
        Contract.hash_data(:account_storage_adapter, "setFieldMainData", [
          {"#{field}_value", field}
        ]),
      gas: Quorum.gas(),
      gasPrice: "0x0"
    }

    {:ok, transaction_hash} = @quorum_client.eth_send_transaction(transaction_data, [])
    :timer.sleep(200)

    assert {:ok, %{"status" => "0x1"}} = @quorum_client.eth_get_transaction_receipt(transaction_hash, [])
  end

  defp add_verification(field, account_address) do
    return_key = UUID.uuid4()
    kimlic_ap_address = Context.get_kimlic_attestation_party_address()
    kimlic_ap_password = Confex.fetch_env!(:quorum, :kimlic_ap_password)
    verification_contract_factory_address = Context.get_verification_contract_factory_address()

    transaction_data = %{
      from: kimlic_ap_address,
      to: verification_contract_factory_address,
      gasPrice: "0x0",
      gas: Quorum.gas(),
      data:
        Contract.hash_data(:verification_contract_factory, "createBaseVerificationContract", [
          {account_address, kimlic_ap_address, return_key, field}
        ])
    }

    @quorum_client.request("personal_unlockAccount", [kimlic_ap_address, kimlic_ap_password], [])
    @quorum_client.eth_send_transaction(transaction_data, [])
    :timer.sleep(120)

    data = Contract.hash_data(:verification_contract_factory, "getVerificationContract", [{return_key}])
    params = %{data: data, to: verification_contract_factory_address}
    {:ok, address} = @quorum_client.eth_call(params, "latest", [])
    contract_address = Context.address64_to_40(address)

    transaction_data = %{
      from: kimlic_ap_address,
      to: contract_address,
      data: Contract.hash_data(:base_verification, "finalizeVerification", [{true}]),
      gasPrice: "0x0",
      gas: Quorum.gas()
    }

    @quorum_client.eth_send_transaction(transaction_data, [])
    :timer.sleep(120)
  end
end
