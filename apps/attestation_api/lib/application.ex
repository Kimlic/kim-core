defmodule AttestationApi.Application do
  @moduledoc false

  use Application

  @spec start(Application.start_type(), list) :: Supervisor.on_start()
  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      supervisor(AttestationApi.Endpoint, []),
      supervisor(AttestationApi.Repo, []),
      worker(AttestationApi.VendorDocuments.Store, [])
    ]

    opts = [strategy: :one_for_one, name: AttestationApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @spec config_change(term, term, term) :: :ok
  def config_change(changed, _new, removed) do
    AttestationApi.Endpoint.config_change(changed, removed)
    :ok
  end
end
