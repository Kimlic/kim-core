defmodule MobileApi.Router do
  @moduledoc false

  use MobileApi, :router
  use Plug.ErrorHandler

  alias MobileApi.Plugs.AccountAddress
  alias MobileApi.Plugs.NodeId
  alias MobileApi.Plugs.PhoneVerificationLimiter
  alias Plug.LoggerJSON

  require Logger

  ### Pipelines

  pipeline :api do
    plug(:accepts, ["json"])
    plug(EView)
    plug(AccountAddress)
  end

  pipeline :create_phone_verification_limiter do
    plug(PhoneVerificationLimiter)
  end

  ### Endpoints

  scope "/api", MobileApi do
    pipe_through(:api)

    scope "/verifications" do
      post("/email", VerificationController, :create_email_verification)
      post("/email/approve", VerificationController, :verify_email)

      scope "/" do
        pipe_through(:create_phone_verification_limiter)
        post("/phone", VerificationController, :create_phone_verification)
      end

      post("/phone/approve", VerificationController, :verify_phone)
    end

    scope "/" do
      post("/push", PushController, :send_push)
    end

    get("/sync", SyncController, :sync_profile)
    get("/config", ConfigController, :get_config)
  end

  scope "/api", MobileApi do
    pipe_through(:quorum_proxy)

    post("/quorum", QuorumController, :proxy)
  end

  @spec handle_errors(Plug.Conn.t(), map) :: Plug.Conn.t()
  defp handle_errors(%Plug.Conn{status: 500} = conn, %{kind: kind, reason: reason, stack: stacktrace}) do
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
    |> send_resp(500, Jason.encode!(%{message: "Internal server error", detail: inspect(reason)}))
  end

  defp handle_errors(_, _), do: nil
end
