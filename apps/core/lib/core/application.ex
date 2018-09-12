defmodule Core.Application do
  @moduledoc false

  use Application
  import Supervisor.Spec

  @spec start(Application.start_type(), list) :: Supervisor.on_start()
  def start(_type, _args) do
    children = [
      worker(Redix, [Application.get_env(:core, Redix, :uri), [name: :redix]])
    ]

    opts = [strategy: :one_for_one, name: Core.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
