defmodule MobileApi.Plugs.PhoneVerificationLimiter do
  @moduledoc """
  Rate limit for phone verification via Hummer
  Read more https://github.com/ExHammer/hammer
  """

  import Plug.Conn
  alias Plug.Conn

  @too_many_requests_status 429

  @spec init(Plug.opts()) :: Plug.opts()
  def init(opts), do: opts

  @doc """
  Check rate limit
  """
  @spec call(Conn.t(), Plug.opts()) :: Conn.t()
  def call(%Conn{params: params, assigns: assigns} = conn, _opts) do
    user_rate_limit_key = "create_phone_verification_limiter:#{assigns.account_address}:#{params["phone"]}"

    case Hammer.check_rate(user_rate_limit_key, timeout(), attempts()) do
      {:allow, _count} -> conn
      _ -> conn |> put_status(@too_many_requests_status) |> halt()
    end
  end

  @spec timeout :: integer
  defp timeout, do: Confex.fetch_env!(:mobile_api, :rate_limit_create_phone_verification_timeout)

  @spec attempts :: integer
  defp attempts, do: Confex.fetch_env!(:mobile_api, :rate_limit_create_phone_verification_attempts)
end
