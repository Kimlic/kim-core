defmodule AttestationApi.DigitalVerificationController.VerificationSubmissionWebhookTest do
  @moduledoc false

  use AttestationApi.ConnCase, async: true
  import AttestationApi.RequestDataFactory

  alias AttestationApi.DigitalVerifications
  alias AttestationApi.DigitalVerifications.DigitalVerification
  alias Ecto.UUID

  @moduletag :account_address

  describe "verification submission webhook" do
    test "verification submitted", %{conn: conn} do
      session_id = UUID.generate()
      veriffme_submitted_code = 7002

      insert(:digital_verification, %{
        status: DigitalVerification.status(:pending),
        account_address: get_account_address(conn),
        session_id: session_id
      })

      request_data = data_for(:digital_verification_submission_webhook, %{"id" => session_id})

      assert conn
             |> post(digital_verification_path(conn, :verification_submission_webhook), request_data)
             |> json_response(200)

      assert %{veriffme_code: ^veriffme_submitted_code} = DigitalVerifications.get_by(%{session_id: session_id})
    end
  end
end
