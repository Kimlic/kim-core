defmodule MobileApi.VerificationControllerTest do
  @moduledoc false

  use MobileApi.ConnCase, async: false

  import Mox

  alias Core.Verifications
  alias Core.Verifications.Verification

  @moduletag :account_address

  @hashed_true "0x0000000000000000000000000000000000000000000000000000000000000001"
  @hashed_false "0x0000000000000000000000000000000000000000000000000000000000000000"

  @entity_type_email Verification.entity_type(:email)
  @entity_type_phone Verification.entity_type(:phone)

  describe "create email verification" do
    test "success", %{conn: conn} do
      account_address = get_account_address(conn)

      expect(QuorumClientMock, :request, 2, fn method, _params, _opts ->
        assert "personal_unlockAccount" == method
        {:ok, true}
      end)

      expect(QuorumContractMock, :eth_call, fn :kimlic_context_storage, function, _args, _opts ->
        assert "getContext" == function
        {:ok, "0x111f4029f7e13575d5f4eab2c65ccc43b21aa67f4cfffff"}
      end)

      expect(QuorumContractMock, :eth_call, fn :kimlic_contracts_context, function, _args, _opts ->
        assert "getAccountStorageAdapter" == function
        {:ok, "0x000000000000000000000000d37debc7b53d678788661c74c94f265b62a412ac"}
      end)

      # Check that Account field email is set
      expect(QuorumContractMock, :eth_call, fn :account_storage_adapter, function, _args, _opts ->
        assert "getFieldHistoryLength" == function
        {:ok, @hashed_true}
      end)

      expect(QuorumContractMock, :eth_call, fn :account_storage_adapter, function, _args, _opts ->
        assert "getLastFieldVerificationContractAddress" == function
        {:ok, @hashed_false}
      end)

      expect(QuorumContractMock, :eth_call, fn :kimlic_context_storage, function, _args, _opts ->
        assert "getContext" == function
        {:ok, "0x111f4029f7e13575d5f4eab2c65ccc43b21aa67f4cfffff"}
      end)

      expect(QuorumContractMock, :eth_call, fn :kimlic_contracts_context, function, _args, _opts ->
        assert "getVerificationContractFactory" == function
        {:ok, "0x111f4029f7e13575d5f4eab2c65ccc43b21aa67f4cfffff"}
      end)

      expect(QuorumContractMock, :call_function, fn :verification_contract_factory, function, _args, _opts ->
        assert "createBaseVerificationContract" == function
        :ok
      end)

      assert %{"data" => %{}, "meta" => %{"code" => 201}} =
               conn
               |> post(verification_path(conn, :create_email_verification), %{email: generate(:email)})
               |> json_response(201)

      assert {:ok, %Verification{token: token, entity_type: @entity_type_email}} =
               Verifications.get(:email, account_address)

      assert token != nil
    end

    test "email not set for account", %{conn: conn} do
      email = generate(:email)

      expect(QuorumClientMock, :request, fn method, _params, _opts ->
        assert "personal_unlockAccount" == method
        {:ok, true}
      end)

      expect(QuorumContractMock, :eth_call, fn :kimlic_context_storage, function, _args, _opts ->
        assert "getContext" == function
        {:ok, "0x111f4029f7e13575d5f4eab2c65ccc43b21aa67f4cfffff"}
      end)

      expect(QuorumContractMock, :eth_call, fn :kimlic_contracts_context, function, _args, _opts ->
        assert "getAccountStorageAdapter" == function
        {:ok, "0x000000000000000000000000d37debc7b53d678788661c74c94f265b62a412ac"}
      end)

      # Check that Account field email is set
      expect(QuorumContractMock, :eth_call, fn :account_storage_adapter, function, _args, _opts ->
        assert "getFieldHistoryLength" == function
        {:ok, @hashed_false}
      end)

      err_message =
        conn
        |> post(verification_path(conn, :create_email_verification), %{email: email})
        |> json_response(409)
        |> get_in(~w(error message))

      assert err_message =~ "Account.email"
    end

    test "email verification contract is already created", %{conn: conn} do
      expect(QuorumClientMock, :request, fn method, _params, _opts ->
        assert "personal_unlockAccount" == method
        {:ok, true}
      end)

      expect(QuorumContractMock, :eth_call, fn :kimlic_context_storage, function, _args, _opts ->
        assert "getContext" == function
        {:ok, "0x111f4029f7e13575d5f4eab2c65ccc43b21aa67f4cfffff"}
      end)

      expect(QuorumContractMock, :eth_call, fn :kimlic_contracts_context, function, _args, _opts ->
        assert "getAccountStorageAdapter" == function
        {:ok, "0x000000000000000000000000d37debc7b53d678788661c74c94f265b62a412ac"}
      end)

      # Check that Account field email is set
      expect(QuorumContractMock, :eth_call, fn :account_storage_adapter, function, _args, _opts ->
        assert "getFieldHistoryLength" == function
        {:ok, @hashed_true}
      end)

      expect(QuorumContractMock, :eth_call, fn :account_storage_adapter, function, _args, _opts ->
        assert "getLastFieldVerificationContractAddress" == function
        {:ok, @hashed_true}
      end)

      expect(QuorumContractMock, :eth_call, fn :base_verification, function, _args, _opts ->
        assert "tokensUnlockAt" == function
        {:ok, :os.system_time(:second) + 10}
      end)

      err_message =
        conn
        |> post(verification_path(conn, :create_email_verification), %{email: generate(:email)})
        |> json_response(409)
        |> get_in(~w(error message))

      assert err_message =~ "for this email"
    end

    test "email verification contract is already created but expires", %{conn: conn} do
      expect(QuorumClientMock, :request, 2, fn method, _params, _opts ->
        assert "personal_unlockAccount" == method
        {:ok, true}
      end)

      expect(QuorumContractMock, :eth_call, fn :kimlic_context_storage, function, _args, _opts ->
        assert "getContext" == function
        {:ok, "0x111f4029f7e13575d5f4eab2c65ccc43b21aa67f4cfffff"}
      end)

      expect(QuorumContractMock, :eth_call, fn :kimlic_contracts_context, function, _args, _opts ->
        assert "getAccountStorageAdapter" == function
        {:ok, "0x000000000000000000000000d37debc7b53d678788661c74c94f265b62a412ac"}
      end)

      # Check that Account field email is set
      expect(QuorumContractMock, :eth_call, fn :account_storage_adapter, function, _args, _opts ->
        assert "getFieldHistoryLength" == function
        {:ok, @hashed_true}
      end)

      expect(QuorumContractMock, :eth_call, fn :account_storage_adapter, function, _args, _opts ->
        assert "getLastFieldVerificationContractAddress" == function
        {:ok, @hashed_true}
      end)

      expect(QuorumContractMock, :eth_call, fn :base_verification, function, _args, _opts ->
        assert "tokensUnlockAt" == function
        {:ok, :os.system_time(:second) - 10}
      end)

      expect(QuorumContractMock, :eth_call, fn :kimlic_context_storage, function, _args, _opts ->
        assert "getContext" == function
        {:ok, "0x111f4029f7e13575d5f4eab2c65ccc43b21aa67f4cfffff"}
      end)

      expect(QuorumContractMock, :eth_call, fn :kimlic_contracts_context, function, _args, _opts ->
        assert "getVerificationContractFactory" == function
        {:ok, "0x111f4029f7e13575d5f4eab2c65ccc43b21aa67f4cfffff"}
      end)

      expect(QuorumContractMock, :call_function, fn :base_verification, "withdraw", _args, _opts -> :ok end)

      expect(QuorumContractMock, :call_function, fn :verification_contract_factory, function, _args, _opts ->
        assert "createBaseVerificationContract" == function
        :ok
      end)

      assert %{"data" => %{}, "meta" => %{"code" => 201}} =
               conn
               |> post(verification_path(conn, :create_email_verification), %{email: generate(:email)})
               |> json_response(201)

      assert {:ok, %Verification{token: token, entity_type: @entity_type_email}} =
               Verifications.get(:email, get_account_address(conn))

      assert token != nil
    end

    test "email param not set", %{conn: conn} do
      assert [err] =
               conn
               |> post(verification_path(conn, :create_email_verification), %{not: :set})
               |> json_response(422)
               |> get_in(~w(error invalid))

      assert "$.email" == err["entry"]
    end

    test "invalid email", %{conn: conn} do
      assert [err] =
               conn
               |> post(verification_path(conn, :create_email_verification), %{email: "invalid.format.com"})
               |> json_response(422)
               |> get_in(~w(error invalid))

      assert "$.email" == err["entry"]
    end
  end

  describe "verify email" do
    test "success", %{conn: conn} do
      expect(QuorumClientMock, :request, fn method, _params, _opts ->
        assert "personal_unlockAccount" == method
        {:ok, true}
      end)

      expect(QuorumContractMock, :call_function, fn :base_verification, "finalizeVerification", _args, _opts -> :ok end)

      account_address = get_account_address(conn)
      %{token: token} = insert(:verification, %{account_address: account_address})

      assert %{"data" => %{"status" => "ok"}} =
               conn
               |> post(verification_path(conn, :verify_email), %{"code" => token})
               |> json_response(200)
    end

    test "not found", %{conn: conn} do
      err =
        conn
        |> post(verification_path(conn, :verify_email), %{"code" => "1234"})
        |> json_response(404)
        |> get_in(~w(error message))

      assert err =~ "Verification not found"
    end

    test "invalid code", %{conn: conn} do
      insert(:verification, %{account_address: get_account_address(conn)})

      err =
        conn
        |> post(verification_path(conn, :verify_email), %{"code" => "1234"})
        |> json_response(404)
        |> get_in(~w(error message))

      assert err =~ "Invalid account address or code"
    end

    test "contract address not set", %{conn: conn} do
      %{token: token} = insert(:verification, %{account_address: get_account_address(conn), contract_address: ""})

      err =
        conn
        |> post(verification_path(conn, :verify_email), %{"code" => token})
        |> json_response(409)
        |> get_in(~w(error message))

      assert err =~ "Verification.contract_address not set yet. Try later"
    end

    test "invalid params", %{conn: conn} do
      assert conn
             |> post(verification_path(conn, :verify_email), %{"code" => 123})
             |> json_response(422)
    end
  end

  describe "create phone verification" do
    test "success", %{conn: conn} do
      account_address = get_account_address(conn)
      phone = generate(:phone)

      expect(QuorumClientMock, :request, 2, fn method, _params, _opts ->
        assert "personal_unlockAccount" == method
        {:ok, true}
      end)

      expect(QuorumContractMock, :eth_call, fn :kimlic_context_storage, function, _args, _opts ->
        assert "getContext" == function
        {:ok, "0x111f4029f7e13575d5f4eab2c65ccc43b21aa67f4cfffff"}
      end)

      expect(QuorumContractMock, :eth_call, fn :kimlic_contracts_context, function, _args, _opts ->
        assert "getAccountStorageAdapter" == function
        {:ok, "0x000000000000000000000000d37debc7b53d678788661c74c94f265b62a412ac"}
      end)

      # Check that Account field phone is set
      expect(QuorumContractMock, :eth_call, fn :account_storage_adapter, function, _args, _opts ->
        assert "getFieldHistoryLength" == function
        {:ok, @hashed_true}
      end)

      expect(QuorumContractMock, :eth_call, fn :account_storage_adapter, function, _args, _opts ->
        assert "getLastFieldVerificationContractAddress" == function
        {:ok, @hashed_false}
      end)

      expect(QuorumContractMock, :eth_call, fn :kimlic_context_storage, function, _args, _opts ->
        assert "getContext" == function
        {:ok, "0x111f4029f7e13575d5f4eab2c65ccc43b21aa67f4cfffff"}
      end)

      expect(QuorumContractMock, :eth_call, fn :kimlic_contracts_context, function, _args, _opts ->
        assert "getVerificationContractFactory" == function
        {:ok, "0x000000000000000000000000d37debc7b53d678788661c74c94f265b62a412ac"}
      end)

      expect(QuorumContractMock, :call_function, fn :verification_contract_factory, function, _args, _opts ->
        assert "createBaseVerificationContract" == function
        :ok
      end)

      conn
      |> post(verification_path(conn, :create_phone_verification), %{phone: phone})
      |> json_response(201)

      assert {:ok, %Verification{token: token, entity_type: @entity_type_phone}} =
               Verifications.get(:phone, account_address)

      assert token != nil
    end

    test "Account.phone not set", %{conn: conn} do
      expect(QuorumContractMock, :eth_call, fn :kimlic_context_storage, function, _args, _opts ->
        assert "getContext" == function
        {:ok, "0x111f4029f7e13575d5f4eab2c65ccc43b21aa67f4cfffff"}
      end)

      expect(QuorumContractMock, :eth_call, fn :kimlic_contracts_context, function, _args, _opts ->
        assert "getAccountStorageAdapter" == function
        {:ok, "0x000000000000000000000000d37debc7b53d678788661c74c94f265b62a412ac"}
      end)

      # Check that Account field phone is set
      expect(QuorumContractMock, :eth_call, fn :account_storage_adapter, "getFieldHistoryLength", _args, _opts ->
        {:ok, @hashed_false}
      end)

      err_message =
        conn
        |> post(verification_path(conn, :create_phone_verification), %{phone: generate(:phone)})
        |> json_response(409)
        |> get_in(~w(error message))

      assert err_message =~ "Account.phone"
    end

    test "Account.phone verification contract already exists", %{conn: conn} do
      phone = generate(:phone)

      expect(QuorumContractMock, :eth_call, fn :kimlic_context_storage, function, _args, _opts ->
        assert "getContext" == function
        {:ok, "0x111f4029f7e13575d5f4eab2c65ccc43b21aa67f4cfffff"}
      end)

      expect(QuorumContractMock, :eth_call, fn :kimlic_contracts_context, function, _args, _opts ->
        assert "getAccountStorageAdapter" == function
        {:ok, "0x000000000000000000000000d37debc7b53d678788661c74c94f265b62a412ac"}
      end)

      # Check that Account field phone is set
      expect(QuorumContractMock, :eth_call, fn :account_storage_adapter, function, _args, _opts ->
        assert "getFieldHistoryLength" == function
        {:ok, @hashed_true}
      end)

      expect(QuorumClientMock, :request, fn method, _params, _opts ->
        assert "personal_unlockAccount" == method
        {:ok, true}
      end)

      expect(QuorumContractMock, :eth_call, fn :account_storage_adapter, function, _args, _opts ->
        assert "getLastFieldVerificationContractAddress" == function
        {:ok, @hashed_true}
      end)

      expect(QuorumContractMock, :eth_call, fn :base_verification, function, _args, _opts ->
        assert "tokensUnlockAt" == function
        {:ok, :os.system_time(:second) + 10}
      end)

      err_message =
        conn
        |> post(verification_path(conn, :create_phone_verification), %{phone: phone})
        |> json_response(409)
        |> get_in(~w(error message))

      assert err_message =~ "for this phone number"
    end

    test "phone param not set", %{conn: conn} do
      assert [err] =
               conn
               |> post(verification_path(conn, :create_phone_verification), %{not: :set})
               |> json_response(422)
               |> get_in(~w(error invalid))

      assert "$.phone" == err["entry"]
    end

    test "invalid phone", %{conn: conn} do
      assert [err] =
               conn
               |> post(verification_path(conn, :create_phone_verification), %{phone: "000111222"})
               |> json_response(422)
               |> get_in(~w(error invalid))

      assert "$.phone" == err["entry"]
    end

    test "with limited requests", %{conn: conn} do
      attempts = Confex.fetch_env!(:mobile_api, :rate_limit_create_phone_verification_attempts)

      expect(QuorumContractMock, :call_function, attempts, fn :verification_contract_factory, function, _args, _opts ->
        assert "createBaseVerificationContract" == function
        :ok
      end)

      stub(QuorumContractMock, :eth_call, fn contract, function, _args, _opts ->
        case {contract, function} do
          {:kimlic_contracts_context, "getVerificationContractFactory"} ->
            {:ok, "0x111f4029f7e13575d5f4eab2c65ccc43b21aa67f4cfffff"}

          {:kimlic_context_storage, "getContext"} ->
            {:ok, "0x111f4029f7e13575d5f4eab2c65ccc43b21aa67f4cfffff"}

          {:kimlic_contracts_context, "getAccountStorageAdapter"} ->
            {:ok, "0x000000000000000000000000d37debc7b53d678788661c74c94f265b62a412ac"}

          {:account_storage_adapter, "getFieldHistoryLength"} ->
            {:ok, @hashed_true}

          {:account_storage_adapter, "getLastFieldVerificationContractAddress"} ->
            {:ok, @hashed_false}
        end
      end)

      expect(QuorumClientMock, :request, attempts * 2, fn method, _params, _opts ->
        assert "personal_unlockAccount" == method
        {:ok, true}
      end)

      phone = generate(:phone)

      do_request = fn ->
        post(conn, verification_path(conn, :create_phone_verification), %{phone: phone})
      end

      for _ <- 1..attempts do
        assert(%{status: code} = do_request.())
        assert 201 == code
      end

      # rate limited requests
      for _ <- 1..10 do
        assert(%{status: code} = do_request.())
        assert 429 == code
      end
    end
  end

  describe "verify phone" do
    test "success", %{conn: conn} do
      expect(QuorumClientMock, :request, fn method, _params, _opts ->
        assert "personal_unlockAccount" == method
        {:ok, true}
      end)

      expect(QuorumContractMock, :call_function, fn :base_verification, "finalizeVerification", _args, _opts -> :ok end)

      account_address = get_account_address(conn)
      %{token: token} = insert(:verification, %{entity_type: @entity_type_phone, account_address: account_address})

      assert %{"data" => %{"status" => "ok"}} =
               conn
               |> post(verification_path(conn, :verify_phone), %{"code" => token})
               |> json_response(200)
    end

    test "not found on phone verification", %{conn: conn} do
      err =
        conn
        |> post(verification_path(conn, :verify_phone), %{"code" => Verifications.generate_token(:phone)})
        |> json_response(404)
        |> get_in(~w(error message))

      assert err =~ "Verification not found"
    end

    test "invalid code", %{conn: conn} do
      insert(:verification, %{entity_type: @entity_type_phone, account_address: get_account_address(conn)})

      err =
        conn
        |> post(verification_path(conn, :verify_phone), %{"code" => "1234"})
        |> json_response(404)
        |> get_in(~w(error message))

      assert err =~ "Invalid account address or code"
    end

    test "contract address not set", %{conn: conn} do
      %{token: token} =
        insert(:verification, %{
          entity_type: @entity_type_phone,
          account_address: get_account_address(conn),
          contract_address: ""
        })

      err =
        conn
        |> post(verification_path(conn, :verify_phone), %{"code" => token})
        |> json_response(409)
        |> get_in(~w(error message))

      assert err =~ "Verification.contract_address not set yet. Try later"
    end

    test "invalid params", %{conn: conn} do
      assert conn
             |> post(verification_path(conn, :verify_phone), %{"code" => 123})
             |> json_response(422)
    end
  end
end
