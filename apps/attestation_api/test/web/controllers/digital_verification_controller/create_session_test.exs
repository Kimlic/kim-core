defmodule AttestationApi.DigitalVerificationController.CreateSessionTest do
  @moduledoc false

  use AttestationApi.ConnCase, async: false

  import AttestationApi.RequestDataFactory
  import Mox

  alias Ecto.UUID

  @moduletag :account_address

  describe "create session" do
    test "success", %{conn: conn} do
      request_data = data_for(:verification_digital_create_session)
      session_id = UUID.generate()

      expect(VeriffmeMock, :create_session, fn _, _, _, _, _ ->
        {:ok,
         %HTTPoison.Response{
           status_code: 201,
           body:
             %{
               "status" => "success",
               "verification" => %{
                 "id" => session_id,
                 "url" => "https://magic.veriff.me/v/",
                 "host" => "https://magic.veriff.me",
                 "status" => "created",
                 "sessionToken" => "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
               }
             }
             |> Jason.encode!()
         }}
      end)

      assert %{"data" => %{"session_id" => ^session_id}} =
               conn
               |> post(digital_verification_path(conn, :create_session), request_data)
               |> json_response(200)
    end

    test "fail with veriffme", %{conn: conn} do
      request_data = data_for(:verification_digital_create_session)

      expect(VeriffmeMock, :create_session, fn _, _, _, _, _ ->
        {:ok,
         %HTTPoison.Response{
           status_code: 400,
           body:
             %{
               "status" => "fail",
               "code" => 1201,
               "error" => "Timestamp must not be older than one hour."
             }
             |> Jason.encode!()
         }}
      end)

      assert %{"error" => %{"message" => _, "type" => "internal_error"}} =
               conn
               |> post(digital_verification_path(conn, :create_session), request_data)
               |> json_response(504)
    end
  end

  describe "validation" do
    test "verification timestamp should not be older than hour from now", %{conn: conn} do
      hour = 60 * 60 + 1
      timestamp_hour_ago = DateTime.to_unix(DateTime.utc_now()) - hour
      request_data = data_for(:verification_digital_create_session, %{"timestamp" => timestamp_hour_ago})

      assert [%{"entry" => "$.timestamp"}] =
               conn
               |> post(digital_verification_path(conn, :create_session), request_data)
               |> json_response(422)
               |> get_in(~w(error invalid))
    end
  end
end
