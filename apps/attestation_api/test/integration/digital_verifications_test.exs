defmodule AttestationApi.Integration.DigitalVerificationsTest do
  @moduledoc false

  use AttestationApi.ConnCase, async: true

  import AttestationApi.RequestDataFactory
  import Mox

  alias AttestationApi.Clients.Veriffme
  alias AttestationApi.DigitalVerifications
  alias AttestationApi.DigitalVerifications.DigitalVerification
  alias AttestationApi.DigitalVerifications.Operations.UploadMedia
  alias Ecto.UUID
  alias Quorum.Contract
  alias Quorum.Contract.Context

  @moduletag :integration

  @quorum_client Application.get_env(:quorum, :client)

  @status_new DigitalVerification.status(:new)
  @status_pending DigitalVerification.status(:pending)
  @document_type "documents.id_card"

  setup :set_mox_global

  @tag :pending
  test "digital verification proccess passes" do
    init_mocks()
    account_address = init_quorum_user()
    verification_address = create_document_contract(account_address)
    session_id = create_session_and_upload_documents(account_address, verification_address)
    run_veriff_webhook(session_id)
    assert_contract_verified(verification_address)
  end

  @spec init_mocks :: :ok
  defp init_mocks do
    expect(VeriffmeMock, :create_session, fn _first_name, _last_name, _lang, _document_type, _unix_timestamp ->
      {:ok,
       %HTTPoison.Response{
         status_code: 201,
         body:
           %{
             "status" => "success",
             "verification" => %{
               "id" => UUID.generate(),
               "url" => "https://magic.veriff.me/v/",
               "host" => "https://magic.veriff.me",
               "status" => "created",
               "sessionToken" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
             }
           }
           |> Jason.encode!()
       }}
    end)

    expect(VeriffmeMock, :upload_media, 3, fn _session_id, context, _image_base64, _unix_timestamp ->
      {:ok,
       %HTTPoison.Response{
         status_code: 200,
         body:
           %{
             "status" => "success",
             "image" => %{
               "id" => UUID.generate(),
               "name" => context
             },
             "url" => "https://api.veriff.me/v1/media/#{UUID.generate()}"
           }
           |> Jason.encode!()
       }}
    end)

    expect(VeriffmeMock, :close_session, fn session_id ->
      {:ok,
       %HTTPoison.Response{
         status_code: 200,
         body:
           %{
             "status" => "success",
             "verification" => %{
               "id" => session_id,
               "url" => "https://magic.veriff.me/v/..",
               "host" => "https://magic.veriff.me",
               "status" => "submitted"
             },
             "url" => "https://api.veriff.me/v1/media/#{UUID.generate()}"
           }
           |> Jason.encode!()
       }}
    end)

    expect(AttestationApiPushMock, :send, fn _message, _device_os, _device_token -> :ok end)

    :ok
  end

  @spec init_quorum_user :: binary
  defp init_quorum_user do
    assert {:ok, account_address} = @quorum_client.request("personal_newAccount", ["p@ssW0rd"], [])
    assert {:ok, _} = @quorum_client.request("personal_unlockAccount", [account_address, "p@ssW0rd"], [])

    transaction_data = %{
      from: account_address,
      to: Context.get_account_storage_adapter_address(),
      data:
        Contract.hash_data(:account_storage_adapter, "setFieldMainData", [
          {"#{:rand.uniform()}", @document_type}
        ]),
      gas: Quorum.gas(),
      gasPrice: "0x0"
    }

    {:ok, transaction_hash} = @quorum_client.eth_send_transaction(transaction_data, [])
    :timer.sleep(100)

    {:ok, %{"status" => "0x1"}} = @quorum_client.eth_get_transaction_receipt(transaction_hash, [])
    :timer.sleep(100)

    account_address
  end

  @spec create_document_contract(binary) :: binary
  defp create_document_contract(account_address) do
    return_key = UUID.generate()
    veriff_ap_address = Application.get_env(:quorum, :veriff_ap_address)
    relaying_party_address = Application.get_env(:quorum, :relying_party_address)
    verification_contract_factory_address = Context.get_verification_contract_factory_address()

    {:ok, _} =
      @quorum_client.request("personal_unlockAccount", [relaying_party_address, "firstRelyingPartyp@ssw0rd"], [])

    transaction_data = %{
      from: relaying_party_address,
      to: verification_contract_factory_address,
      data:
        Contract.hash_data(:verification_contract_factory, "createBaseVerificationContract", [
          {account_address, veriff_ap_address, return_key, @document_type}
        ]),
      gas: Quorum.gas(),
      gasPrice: "0x0"
    }

    {:ok, transaction_hash} = @quorum_client.eth_send_transaction(transaction_data, [])
    :timer.sleep(100)

    {:ok, %{"status" => "0x1"}} = @quorum_client.eth_get_transaction_receipt(transaction_hash, [])
    :timer.sleep(100)

    params = %{
      data: Contract.hash_data(:verification_contract_factory, "getVerificationContract", [{return_key}]),
      to: verification_contract_factory_address
    }

    {:ok, document_verification_address} = @quorum_client.eth_call(params, "latest", [])

    Context.address64_to_40(document_verification_address)
  end

  @spec create_session_and_upload_documents(binary, binary) :: binary
  defp create_session_and_upload_documents(account_address, verification_address) do
    assert {:ok, session_id} =
             DigitalVerifications.create_session(
               account_address,
               data_for(:verification_digital_create_session, %{"contract_address" => verification_address})
             )

    assert %DigitalVerification{
             account_address: ^account_address,
             contract_address: ^verification_address,
             status: @status_new
           } = DigitalVerifications.get_by(%{session_id: session_id})

    for context <- Veriffme.contexts() do
      verification_data =
        data_for(:digital_verification_upload_media, %{
          "session_id" => session_id,
          "context" => context
        })

      assert :ok = UploadMedia.handle(verification_data)
    end

    assert %DigitalVerification{status: @status_pending} = DigitalVerifications.get_by(%{session_id: session_id})

    session_id
  end

  @spec run_veriff_webhook(binary) :: :ok
  defp run_veriff_webhook(session_id) do
    veriffme_decision_data =
      data_for(:digital_verification_result_webhook, %{
        "verification" => %{
          "id" => session_id,
          "status" => "approved",
          "code" => 9001
        }
      })

    assert :ok = DigitalVerifications.handle_verification_result(veriffme_decision_data)
  end

  @spec assert_contract_verified(binary) :: {:ok, binary}
  defp assert_contract_verified(contract_address) do
    :timer.sleep(100)
    data = Contract.hash_data(:base_verification, "getStatus", [{}])
    verified_status = "0x0000000000000000000000000000000000000000000000000000000000000002"

    assert {:ok, ^verified_status} = @quorum_client.eth_call(%{to: contract_address, data: data}, "latest", [])
  end
end
