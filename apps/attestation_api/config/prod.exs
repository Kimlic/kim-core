use Mix.Config

config :attestation_api, AttestationApi.Endpoint,
  debug_errors: false,
  catch_errors: true,
  code_reloader: false,
  check_origin: false
  
config :attestation_api, AttestationApi.Repo,
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASSWORD"),
  database: System.get_env("DB_NAME"),
  hostname: System.get_env("DB_HOST"),
  pool_size: System.get_env("DB_POOL") |> Integer.parse |> elem(0),
  loggers: [{Ecto.LoggerJSON, :log, [:info]}]

config :attestation_api, push_url: System.get_env("PUSH_URL")
