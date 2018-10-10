defmodule AttestationApi.Router do
  @moduledoc false

  use AttestationApi, :router
  use Plug.ErrorHandler

  alias AttestationApi.Plugs.AccountAddress
  alias Plug.LoggerJSON

  require Logger

  @http_server_error_codes 500..505

  ### Pipelines

  pipeline :api do
    plug(:accepts, ["json"])
    plug(AccountAddress)
  end

  pipeline :eview_response do
    plug(EView)
  end

  pipeline :accepts_json do
    plug(:accepts, ["json"])
  end

  ### Endpoints

  scope "/api/verifications/digital", AttestationApi do
    pipe_through([:api, :eview_response])

    post("/sessions", DigitalVerificationController, :create_session)
    post("/sessions/:session_id/media", DigitalVerificationController, :upload_media)

    get("/vendors", DigitalVerificationController, :get_vendors)
  end

  scope "/api", AttestationApi do
    pipe_through(:accepts_json)

    post("/verifications/digital/submission", DigitalVerificationController, :verification_submission_webhook)
    post("/verifications/digital/decision", DigitalVerificationController, :verification_result_webhook)

    get "/verifications/:session_id", DigitalVerificationController, :verification_info
  end

  @spec handle_errors(Plug.Conn.t(), map) :: Plug.Conn.t()
  defp handle_errors(%Plug.Conn{status: status_code} = conn, %{kind: kind, reason: reason, stack: stacktrace})
       when status_code in @http_server_error_codes do
    LoggerJSON.log_error(kind, reason, stacktrace)

    Logger.log(:info, fn ->
      Jason.encode!(%{
        "log_type" => "error",
        "request_params" => conn.params,
        "request_id" => Logger.metadata()[:request_id]
      })
    end)

    conn
    |> put_resp_header("content-type", "application/json; charset=utf-8")
    |> send_resp(status_code, Jason.encode!(%{message: "Internal server error", detail: inspect(reason)}))
  end

  defp handle_errors(_, _), do: nil
end
