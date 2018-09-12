defmodule MobileApi.Plugs.PhoneVerificationLimiterTest do
  @moduledoc false

  use MobileApi.ConnCase, async: false
  import Plug.Conn
  alias MobileApi.Plugs.PhoneVerificationLimiter

  describe "testing phone verification limiter" do
    setup %{conn: conn} do
      conn =
        conn
        |> Map.put(:params, %{"_format" => "json", "phone" => generate(:phone)})
        |> assign(:account_address, generate(:account_address))

      {:ok, conn: conn}
    end

    test "success", %{conn: conn} do
      assert %Plug.Conn{status: nil} = PhoneVerificationLimiter.call(conn, [])
    end

    test "limit achieved", %{conn: conn} do
      attempts = Application.get_env(mobile_api, :rate_limit_create_phone_verification_attempts)

      for _ <- 1..attempts,
          do: assert(%Plug.Conn{status: nil} = PhoneVerificationLimiter.call(conn, []))

      # rate limited requests
      for _ <- 1..attempts,
          do: assert(%Plug.Conn{status: 429} = PhoneVerificationLimiter.call(conn, []))
    end

    test "plug init" do
      assert [] == PhoneVerificationLimiter.init([])
    end
  end
end
