defmodule AttestationApi.DigitalVerificationController.VerificationResultWebhookTest do
  @moduledoc false

  use AttestationApi.ConnCase, async: false

  import AttestationApi.RequestDataFactory
  import Mox

  alias AttestationApi.DigitalVerifications
  alias AttestationApi.DigitalVerifications.DigitalVerification
  alias AttestationApi.DigitalVerifications.DigitalVerificationDocument
  alias AttestationApi.Repo
  alias Ecto.UUID

  @moduletag :account_address

  setup :verify_on_exit!

  describe "verification result webhook" do
    setup do
      expect(AttestationApiPushMock, :send, fn _message, _device_os, _device_token -> :ok end)

      expect(QuorumClientMock, :request, fn method, _params, _opts ->
        assert "personal_unlockAccount" == method
        {:ok, true}
      end)

      expect(QuorumContractMock, :call_function, fn :base_verification, "finalizeVerification", _args, _opts -> :ok end)

      :ok
    end

    test "verification approved", %{conn: conn} do
      %{id: verification_id, session_id: session_id} = prepare_success_data(conn)

      insert(:digital_verification_document, %{verification_id: verification_id, context: "face"})
      insert(:digital_verification_document, %{verification_id: verification_id, context: "document-front"})
      insert(:digital_verification_document, %{verification_id: verification_id, context: "document-back"})

      request_data =
        data_for(:digital_verification_result_webhook, %{
          "verification" => %{
            "id" => session_id,
            "status" => "approved",
            "code" => 9001
          }
        })

      assert conn
             |> post(digital_verification_path(conn, :verification_result_webhook), request_data)
             |> json_response(200)

      status_passed = DigitalVerification.status(:passed)
      assert %{status: ^status_passed} = DigitalVerifications.get_by(%{session_id: session_id})

      assert [] = Repo.all(DigitalVerificationDocument)
    end

    test "empty verification documents", %{conn: conn} do
      %{session_id: session_id} = prepare_success_data(conn)

      request_data =
        data_for(:digital_verification_result_webhook, %{
          "verification" => %{
            "id" => session_id,
            "status" => "approved",
            "code" => 9001
          }
        })

      assert conn
             |> post(digital_verification_path(conn, :verification_result_webhook), request_data)
             |> json_response(200)
    end

    test "verification declined", %{conn: conn} do
      %{session_id: session_id} = prepare_success_data(conn)
      fail_code = 9102

      request_data =
        data_for(:digital_verification_result_webhook, %{
          "verification" => %{
            "id" => session_id,
            "status" => "declined",
            "code" => fail_code,
            "reason" => "Person has not been verified",
            "comment" => [
              %{
                "type" => "video_call_comment",
                "comment" => "Person is from Bangladesh",
                "timestamp" => "2018-05-19T08:30:25.597Z"
              }
            ]
          }
        })

      assert conn
             |> post(digital_verification_path(conn, :verification_result_webhook), request_data)
             |> json_response(200)

      status_failed = DigitalVerification.status(:failed)

      assert %{status: ^status_failed, veriffme_code: ^fail_code} =
               DigitalVerifications.get_by(%{session_id: session_id})
    end

    test "verification ressubmission required", %{conn: conn} do
      %{session_id: session_id} = prepare_success_data(conn)
      ressubmission_code = 9103

      request_data =
        data_for(:digital_verification_result_webhook, %{
          "verification" => %{
            "id" => session_id,
            "status" => "resubmission_requested",
            "code" => ressubmission_code,
            "reason" => "Resubmission_requested",
            "comment" => []
          }
        })

      assert conn
             |> post(digital_verification_path(conn, :verification_result_webhook), request_data)
             |> json_response(200)

      status_resubmission_requested = DigitalVerification.status(:resubmission_requested)

      assert %{status: ^status_resubmission_requested, veriffme_code: ^ressubmission_code} =
               DigitalVerifications.get_by(%{session_id: session_id})
    end

    test "verification not found on second call", %{conn: conn} do
      %{session_id: session_id} = prepare_success_data(conn)

      request_data =
        data_for(:digital_verification_result_webhook, %{
          "verification" => %{
            "id" => session_id,
            "status" => "approved",
            "code" => 9001
          }
        })

      assert conn
             |> post(digital_verification_path(conn, :verification_result_webhook), request_data)
             |> json_response(200)

      assert conn
             |> post(digital_verification_path(conn, :verification_result_webhook), request_data)
             |> json_response(404)
    end
  end

  defp prepare_success_data(conn) do
    session_id = UUID.generate()

    insert(:digital_verification, %{
      status: DigitalVerification.status(:pending),
      account_address: get_account_address(conn),
      session_id: session_id
    })
  end
end
