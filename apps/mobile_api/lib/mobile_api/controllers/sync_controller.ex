defmodule MobileApi.SyncController do
  @moduledoc false

  use MobileApi, :controller
  alias Core.Sync
  require Logger

  action_fallback(MobileApi.FallbackController)

  @doc """
  Renders data_fields with result of Core.Sync.handle
  """
  @spec sync_profile(Conn.t(), map) :: Conn.t()
  def sync_profile(conn, _params) do
    Log.info(%{"message" => "#{__MODULE__} Request sync_profile", "log_tag" => "profile_sync"})
    Log.warn(%{"message" => "#{__MODULE__} Request sync_profile", "log_tag" => "profile_sync"})
    Log.error(%{"message" => "#{__MODULE__} Request sync_profile", "log_tag" => "profile_sync"})

    Logger.warn(fn ->
      %{"message" => "#{__MODULE__} Request sync_profile from elixir Logger", "log_tag" => "profile_sync"}
      |> Jason.encode!()
    end)

    sync_data = Sync.handle(conn.assigns.account_address)

    json(conn, %{"data_fields" => sync_data})
  end
end
