use Mix.Config

config :attestation_api, AttestationApi.Endpoint,
  debug_errors: false,
  catch_errors: true,
  code_reloader: true,
  check_origin: false

config :attestation_api, AttestationApi.Repo,
  username: "kimlic",
  password: "kimlic",
  database: "attestation_api_dev",
  hostname: "localhost",
  pool_size: 10,
  loggers: [{Ecto.LoggerJSON, :log, [:debug]}]

config :attestation_api, push_url: "http://127.0.0.1:4000"

config :phoenix, :stacktrace_depth, 20
