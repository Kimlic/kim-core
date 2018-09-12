defmodule MobileApi.VerificationController do
  @moduledoc false

  use MobileApi, :controller

  alias Core.Verifications
  alias Core.Verifications.Verification
  alias MobileApi.FallbackController
  alias MobileApi.Plugs.RequestValidator
  alias MobileApi.Validators.Verification.{ApproveValidator, EmailValidator, PhoneValidator}
  alias Plug.Conn

  action_fallback(FallbackController)

  plug(RequestValidator, [validator: ApproveValidator] when action in ~w(verify_email verify_phone)a)
  plug(RequestValidator, [validator: EmailValidator] when action == :create_email_verification)
  plug(RequestValidator, [validator: PhoneValidator] when action == :create_phone_verification)

  @doc """
  Create email verification
  """
  @spec create_email_verification(Conn.t(), map) :: Conn.t()
  def create_email_verification(conn, params) do
    account_address = conn.assigns.account_address

    with {:ok, verification} <- Verifications.create_email_verification(params["email"], account_address) do
      conn
      |> put_status(201)
      |> send_debug_info(verification)
      |> json(%{})
    end
  end

  @doc """
  Verify email with passed code
  """
  @spec verify_email(Conn.t(), map) :: Conn.t()
  def verify_email(conn, params) do
    with :ok <- Verifications.verify(:email, conn.assigns.account_address, params["code"]) do
      json(conn, %{status: "ok"})
    end
  end

  @doc """
  Create phone verification
  """
  @spec create_phone_verification(Conn.t(), map) :: Conn.t()
  def create_phone_verification(conn, params) do
    account_address = conn.assigns.account_address

    with {:ok, verification} <- Verifications.create_phone_verification(params["phone"], account_address) do
      conn
      |> put_status(201)
      |> send_debug_info(verification)
      |> json(%{})
    end
  end

  @doc """
  Verify phone with passed code
  """
  @spec verify_phone(Conn.t(), map) :: Conn.t()
  def verify_phone(conn, params) do
    with :ok <- Verifications.verify(:phone, conn.assigns.account_address, params["code"]) do
      json(conn, %{status: "ok"})
    end
  end

  @spec send_debug_info(Conn.t(), %Verification{}) :: Conn.t()
  defp send_debug_info(conn, %Verification{token: token}) do
    case Application.get_env(:mobile_api, :debug_info_enabled) do
      true -> put_resp_header(conn, "debug-verification-token", token)
      false -> conn
    end
  end
end
