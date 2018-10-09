defmodule MobileApi.PushController do
  @moduledoc false

  use MobileApi, :controller

  alias Core.Push
  alias MobileApi.FallbackController
  alias MobileApi.Plugs.RequestValidator
  alias MobileApi.Validators.Push.SendPushValidator
  alias Plug.Conn

  action_fallback(FallbackController)

  plug(RequestValidator, [validator: SendPushValidator, error_handler: FallbackController] when action == :send_push)

  @doc """
  Send push to Mobile device
  """
  @spec send_push(Conn.t(), map) :: Conn.t()
  def send_push(conn, %{"message" => message, "device_os" => device_os, "device_token" => device_token}) do
    with :ok <- Push.enqueue(message, device_os, device_token) do
      json(conn, %{"status" => "ok"})
    end
  end
end
