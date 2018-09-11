defmodule Core.VerificationsTest do
  @moduledoc false

  use ExUnit.Case, async: true

  import Core.Factory
  import Mox

  alias Core.Clients.Redis
  alias Core.Verifications

  test "handle update_verification_contract_address callback with email" do
    assert_handle_callback("email", generate(:email))
  end

  test "handle update_verification_contract_address callback with phone" do
    phone = generate(:phone)
    expect(MessengerMock, :send, fn ^phone, _message -> {:ok, %{}} end)

    assert_handle_callback("phone", phone)
  end

  @spec assert_handle_callback(binary, binary) :: binary
  defp assert_handle_callback(entity_type, destination) do
    account_address = generate(:account_address)
    contract_address = generate(:account_address)

    verification_data = %{
      account_address: account_address,
      contract_address: nil,
      entity_type: String.upcase(entity_type)
    }

    %{redis_key: redis_key} = insert(:verification, verification_data)

    assert :ok =
             Verifications.update_verification_contract_address(
               account_address,
               entity_type,
               destination,
               "0x1",
               {:ok, contract_address}
             )

    assert {:ok, %{contract_address: ^contract_address}} = Redis.get(redis_key)
  end
end
