{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start()
ExUnit.configure(exclude: [pending: true])

Ecto.Adapters.SQL.Sandbox.mode(AttestationApi.Repo, :manual)
