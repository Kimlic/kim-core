defmodule Quorum.Integration.DirectQuorumTest do
  use ExUnit.Case

  alias Quorum.Contract
  alias Quorum.Contract.Context
  alias Quorum.Contract.AccountStorageAdapter
  alias Quorum.Contract.BaseVerification

  @quorum_client Application.get_env(:quorum, :client)

  @hashed_true "0x0000000000000000000000000000000000000000000000000000000000000001"
  @hashed_false "0x0000000000000000000000000000000000000000000000000000000000000000"

  @tag :pending
  test "create Email verification contract" do
    account_address = init_quorum_user()
    kimlic_ap_address = Context.get_kimlic_attestation_party_address()
    kimlic_ap_password = Application.get_env(quorum, :kimlic_ap_password)
    verification_contract_factory_address = Context.get_verification_contract_factory_address()

    assert {:ok, _} = @quorum_client.request("personal_unlockAccount", [account_address, "p@ssW0rd"], [])
    assert {:ok, _} = @quorum_client.request("personal_unlockAccount", [kimlic_ap_address, kimlic_ap_password], [])

    # create Base verification contract form email
    #
    return_key = UUID.uuid4()

    data =
      Contract.hash_data(:verification_contract_factory, "createBaseVerificationContract", [
        {account_address, kimlic_ap_address, return_key, "email"}
      ])

    tx_data = %{
      from: kimlic_ap_address,
      data: data,
      to: verification_contract_factory_address,
      gasPrice: "0x0",
      gas: Quorum.gas()
    }

    assert {:ok, transaction_hash} = @quorum_client.eth_send_transaction(tx_data)

    :timer.sleep(70)
    assert {:ok, map} = @quorum_client.eth_get_transaction_receipt(transaction_hash, [])
    assert is_map(map), "Expected map from Quorum.eth_get_transaction_receipt, get: #{inspect(map)}"
    msg = "Invalid transaction status. Expected \"0x1\", get: #{map["status"]}"
    assert "0x1" == map["status"], msg

    # get created verification contract address
    #
    data = Contract.hash_data(:verification_contract_factory, "getVerificationContract", [{return_key}])

    :timer.sleep(50)

    assert {:ok, contract_address} = @quorum_client.eth_call(%{data: data, to: verification_contract_factory_address})
    msg = "Expected address from Quorum.getVerificationContract, get: #{inspect(contract_address)}"
    assert is_binary(contract_address), msg
    refute @hashed_false == contract_address

    contract_address = Context.address64_to_40(contract_address)

    # finalize verification
    #
    data = Contract.hash_data(:base_verification, "finalizeVerification", [{true}])

    tx_data = %{
      from: kimlic_ap_address,
      data: data,
      to: contract_address,
      gasPrice: "0x0",
      gas: Quorum.gas()
    }

    assert {:ok, transaction_hash} = @quorum_client.eth_send_transaction(tx_data)

    :timer.sleep(70)
    assert {:ok, map} = @quorum_client.eth_get_transaction_receipt(transaction_hash, [])
    assert is_map(map), "Expected map from Quorum.eth_get_transaction_receipt, get: #{inspect(map)}"
    msg = "Invalid transaction status. Expected \"0x1\", get: #{map["status"]}"
    assert "0x1" == map["status"], msg
  end

  @tag :pending
  test "withdraw tokens" do
    account_address = init_quorum_user()
    kimlic_ap_address = Context.get_kimlic_attestation_party_address()
    kimlic_ap_password = Application.get_env(quorum, :kimlic_ap_password)
    verification_contract_factory_address = Context.get_verification_contract_factory_address()

    assert {:ok, _} = @quorum_client.request("personal_unlockAccount", [account_address, "p@ssW0rd"], [])
    assert {:ok, _} = @quorum_client.request("personal_unlockAccount", [kimlic_ap_address, kimlic_ap_password], [])

    # create Base verification contract form email
    #
    return_key = UUID.uuid4()

    data =
      Contract.hash_data(:verification_contract_factory, "createBaseVerificationContract", [
        {account_address, kimlic_ap_address, return_key, "email"}
      ])

    tx_data = %{
      from: kimlic_ap_address,
      data: data,
      to: verification_contract_factory_address,
      gasPrice: "0x0",
      gas: Quorum.gas()
    }

    assert {:ok, transaction_hash} = @quorum_client.eth_send_transaction(tx_data)

    :timer.sleep(70)
    assert {:ok, map} = @quorum_client.eth_get_transaction_receipt(transaction_hash, [])
    assert is_map(map), "Expected map from Quorum.eth_get_transaction_receipt, get: #{inspect(map)}}"
    msg = "Invalid transaction status. Expected \"0x1\", get: #{map["status"]}"
    assert "0x1" == map["status"], msg

    # get created verification contract address
    #
    data = Contract.hash_data(:verification_contract_factory, "getVerificationContract", [{return_key}])

    :timer.sleep(50)

    assert {:ok, contract_address} = @quorum_client.eth_call(%{data: data, to: verification_contract_factory_address})
    msg = "Expected address from Quorum.getVerificationContract, get: #{inspect(contract_address)}"
    assert is_binary(contract_address), msg
    refute @hashed_false == contract_address

    contract_address = Context.address64_to_40(contract_address)

    # check contract expiration time
    #
    user_address = Application.get_env(quorum, :profile_sync_user_address)
    password = Application.get_env(quorum, :profile_sync_user_password)
    assert {:ok, _} = @quorum_client.request("personal_unlockAccount", [user_address, password], [])

    # get tokensUnlockAt from contract
    data = Contract.hash_data(:base_verification, "tokensUnlockAt", [])
    params = %{data: data, from: user_address, to: contract_address}

    assert {:ok, _hashed_time} = @quorum_client.eth_call(params)

    assert {:ok, time} = BaseVerification.tokens_unlock_at(%{from: user_address, to: contract_address})
    assert is_integer(time)

    # withdraw tokens
    assert :ok = BaseVerification.withdraw(%{from: user_address, to: contract_address})
  end

  @tag :pending
  test "check that account field email not set" do
    assert {:ok, account_address} = @quorum_client.request("personal_newAccount", ["p@ssW0rd"], [])

    params = %{
      to: Context.get_account_storage_adapter_address(),
      data: Contract.hash_data(:account_storage_adapter, "getFieldHistoryLength", [{account_address, "email"}])
    }

    assert {:ok, @hashed_false} = @quorum_client.eth_call(params)
  end

  @tag :pending
  test "check that account field email set" do
    account_address = init_quorum_user()
    assert {:ok, _} = @quorum_client.request("personal_unlockAccount", [account_address, "p@ssW0rd"], [])

    assert {:ok, @hashed_true} =
             AccountStorageAdapter.get_field_history_length(
               account_address,
               "email",
               %{to: Context.get_account_storage_adapter_address()}
             )
  end

  defp init_quorum_user do
    assert {:ok, account_address} = @quorum_client.request("personal_newAccount", ["p@ssW0rd"], [])
    assert {:ok, _} = @quorum_client.request("personal_unlockAccount", [account_address, "p@ssW0rd"], [])

    transaction_data = %{
      from: account_address,
      to: Context.get_account_storage_adapter_address(),
      data:
        Contract.hash_data(:account_storage_adapter, "setFieldMainData", [
          {"#{:rand.uniform()}", "email"}
        ]),
      gasPrice: "0x0",
      gas: Quorum.gas()
    }

    {:ok, transaction_hash} = @quorum_client.eth_send_transaction(transaction_data, [])
    :timer.sleep(75)

    {:ok, %{"status" => "0x1"}} = @quorum_client.eth_get_transaction_receipt(transaction_hash, [])
    :timer.sleep(75)

    account_address
  end
end
