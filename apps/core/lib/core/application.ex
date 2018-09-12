defmodule Core.Application do
  @moduledoc false

  use Application
  import Supervisor.Spec

  @spec start(Application.start_type(), list) :: Supervisor.on_start()
  def start(_type, _args) do
    children = [
      worker(Redix, [[
        host: Application.get_env(:core, :redis_host), 
        port: Application.get_env(:core, :redis_port), 
        password: Application.get_env(:core, :redis_password)
      ], [name: :redix]])
    ]

    opts = [strategy: :one_for_one, name: Core.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
