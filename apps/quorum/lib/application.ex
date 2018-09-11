defmodule Quorum.Application do
  @moduledoc false

  use Application
  import Supervisor.Spec

  @spec start(Application.start_type(), list) :: Supervisor.on_start()
  def start(_type, _args) do
    children = [
      worker(Quorum.Contract.Store, [])
    ]

    opts = [strategy: :one_for_one, name: Quorum.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
