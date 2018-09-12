use Mix.Config

config :attestation_api, AttestationApi.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY"),
  http: [port: System.get_env("PORT")],
  url: [
    host: System.get_env("HOST"),
    port: System.get_env("PORT")
  ],
  load_from_system_env: true,
  debug_errors: false,
  catch_errors: true,
  code_reloader: false

config :attestation_api, AttestationApi.Repo,
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASSWORD"),
  database: System.get_env("DB_NAME"),
  hostname: System.get_env("DB_HOST"),
  port: System.get_env("DB_PORT"),
  timeout: 15_000,
  pool_timeout: 15_000,
  ownership_timeout: 15_000,
  pool_size: System.get_env("DB_POOL_SIZE"),
  parameters: [application_name: "AttestationApi", statement_timeout: "5000"],
  loggers: [{Ecto.LoggerJSON, :log, [:info]}]

config :attestation_api, AttestationApi.Clients.Veriffme,
  api_url: System.get_env("VERIFFME_API_URL"),
  auth_client: System.get_env("VERIFFME_AUTH_CLIENT"),
  api_secret: System.get_env("VERIFFME_API_SECRET")

config :attestation_api, AttestationApi.Clients.Push, push_url: System.get_env("PUSH_URL")

config :ecto_logger_json, truncate_params: true

config :logger, level: :info
