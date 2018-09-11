defmodule MobileApi.ConfigController do
  @moduledoc """
  ConfigController
  """

  use MobileApi, :controller
  alias Core.ConfigKeeper
  action_fallback(MobileApi.FallbackController)

  @doc """
  Render application config
  """
  @spec get_config(Conn.t(), map) :: Conn.t()
  def get_config(conn, _params) do
    json(conn, ConfigKeeper.all())
  end
end
