defmodule MobileApi.Unit.VerificationsTest do
  @moduledoc false

  use ExUnit.Case

  import Core.Factory
  import ExUnit.CaptureLog
  import Mox

  alias Core.Clients.Redis
  alias Core.Verifications
  alias Core.Verifications.Verification

  describe "update_verification_contract_address" do
    test "success with email" do
      call_success_path_test(:email)
    end

    test "success with phone" do
      expect(MessengerMock, :send, fn _to, _message ->
        {:ok, %ExTwilio.Message{}}
      end)

      call_success_path_test(:phone)
    end

    test "logs on error" do
      err_reason = "Something went wrong"
      expected = "fail to update verification contract address with info: "

      update_verification_fail = fn ->
        Verifications.update_verification_contract_address(
          generate(:account_address),
          "email",
          generate(:email),
          %{},
          {:error, err_reason}
        )
      end

      assert capture_log(update_verification_fail) =~ err_reason
      assert capture_log(update_verification_fail) =~ expected
    end
  end

  @spec call_success_path_test(atom) :: :ok
  defp call_success_path_test(entity_type) do
    verification = insert(:verification, %{contract_address: nil, entity_type: Verification.entity_type(entity_type)})
    verification_type = String.downcase(verification.entity_type)
    destination = generate(entity_type)
    contract_address = generate(:account_address)

    assert :ok =
             Verifications.update_verification_contract_address(
               verification.account_address,
               verification_type,
               destination,
               %{},
               {:ok, contract_address}
             )

    assert {:ok, %Verification{contract_address: ^contract_address}} = Redis.get(verification.redis_key)
  end
end
