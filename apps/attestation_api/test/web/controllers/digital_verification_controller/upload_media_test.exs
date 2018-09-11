defmodule AttestationApi.DigitalVerificationController.UploadMediaTest do
  @moduledoc false

  use AttestationApi.ConnCase, async: false

  import AttestationApi.RequestDataFactory
  import Mox

  alias AttestationApi.DigitalVerifications
  alias AttestationApi.DigitalVerifications.DigitalVerification
  alias Ecto.UUID

  @moduletag :account_address

  @status_new DigitalVerification.status(:new)
  @status_pending DigitalVerification.status(:pending)

  setup :set_mox_global

  describe "upload media" do
    test "success: all documents loaded (face, document-front, document-back)", %{conn: conn} do
      expect_success()
      {session_id, request_data} = prepare_success_data(conn)

      assert %{"data" => %{"status" => "ok"}} =
               conn
               |> post(digital_verification_path(conn, :upload_media, session_id), request_data)
               |> json_response(200)

      assert %DigitalVerification{status: @status_pending} = DigitalVerifications.get_by(%{session_id: session_id})
    end

    test "success: partial document loading (document-back needed)", %{conn: conn} do
      expect_success()
      session_id = UUID.generate()

      %{id: verification_id} =
        insert(:digital_verification, %{account_address: get_account_address(conn), session_id: session_id})

      request_data = data_for(:digital_verification_upload_media, %{"context" => "face"})
      insert(:digital_verification_document, %{verification_id: verification_id, context: "document-front"})

      assert %{"data" => %{"status" => "ok"}} =
               conn
               |> post(digital_verification_path(conn, :upload_media, session_id), request_data)
               |> json_response(200)

      assert %DigitalVerification{status: @status_new} = DigitalVerifications.get_by(%{session_id: session_id})
    end

    test "success: load first document", %{conn: conn} do
      expect_success()
      session_id = UUID.generate()
      insert(:digital_verification, %{account_address: get_account_address(conn), session_id: session_id})

      request_data = data_for(:digital_verification_upload_media, %{"context" => "face"})

      assert %{"data" => %{"status" => "ok"}} =
               conn
               |> post(digital_verification_path(conn, :upload_media, session_id), request_data)
               |> json_response(200)

      assert %DigitalVerification{status: @status_new} = DigitalVerifications.get_by(%{session_id: session_id})
    end

    test "fail to upload media", %{conn: conn} do
      expect(VeriffmeMock, :upload_media, 3, fn _session_id, _context, _image_base64, _unix_timestamp ->
        {:ok,
         %HTTPoison.Response{
           status_code: 400,
           body: "{\"status\":\"fail\",\"code\":\"1002\",\"error\":\"Query ID must be a valid UUID V4\"}"
         }}
      end)

      {session_id, request_data} = prepare_success_data(conn)

      assert %{"error" => %{"type" => "internal_error", "message" => _}} =
               conn
               |> post(digital_verification_path(conn, :upload_media, session_id), request_data)
               |> json_response(500)
    end

    test "fail to close veriffme session", %{conn: conn} do
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

      expect(VeriffmeMock, :close_session, fn _session_id ->
        {:ok,
         %HTTPoison.Response{
           status_code: 400,
           body: "{\"status\":\"fail\",\"code\":\"1002\",\"error\":\"Query ID must be a valid UUID V4\"}"
         }}
      end)

      {session_id, request_data} = prepare_success_data(conn)

      assert %{"error" => %{"type" => "internal_error", "message" => _}} =
               conn
               |> post(digital_verification_path(conn, :upload_media, session_id), request_data)
               |> json_response(500)

      assert %DigitalVerification{status: @status_new} = DigitalVerifications.get_by(%{session_id: session_id})
    end

    test "invalid session id", %{conn: conn} do
      session_id = UUID.generate()
      invalid_session_id = UUID.generate()
      request_data = data_for(:digital_verification_upload_media)
      insert(:digital_verification, %{account_address: get_account_address(conn), session_id: session_id})

      assert [err] =
               conn
               |> post(
                 digital_verification_path(conn, :upload_media, invalid_session_id),
                 request_data
               )
               |> json_response(422)
               |> get_in(~w(error invalid))

      assert %{"entry" => "$.session_id"} = err
    end

    test "base64 image size should be less than 5mb", %{conn: conn} do
      session_id = UUID.generate()
      insert(:digital_verification, %{account_address: get_account_address(conn), session_id: session_id})

      # 5.1 mb
      content = String.duplicate("Q123", 1_350_000)
      request_data = data_for(:digital_verification_upload_media, %{"content" => content})

      assert conn
             |> post(digital_verification_path(conn, :upload_media, session_id), request_data)
             |> json_response(422)

      # 4.99 mb
      content = String.duplicate("Q123", 1_300_000)
      request_data = data_for(:digital_verification_upload_media, %{"content" => content})

      assert conn
             |> post(digital_verification_path(conn, :upload_media, session_id), request_data)
             |> json_response(200)
    end
  end

  defp prepare_success_data(conn) do
    session_id = UUID.generate()
    request_data = data_for(:digital_verification_upload_media, %{"context" => "face"})

    %{id: verification_id} =
      insert(:digital_verification, %{account_address: get_account_address(conn), session_id: session_id})

    insert(:digital_verification_document, %{verification_id: verification_id, context: "document-front"})
    insert(:digital_verification_document, %{verification_id: verification_id, context: "document-back"})

    {session_id, request_data}
  end

  defp expect_success do
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
  end
end
