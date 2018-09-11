use Mix.Config

config :attestation_api, AttestationApi.Endpoint,
  secret_key_base: {:system, "SECRET_KEY"},
  http: [port: {:system, :integer, "PORT"}],
  url: [
    host: {:system, "HOST"},
    port: {:system, :integer, "PORT"}
  ],
  load_from_system_env: true,
  debug_errors: false,
  catch_errors: true,
  code_reloader: false

config :attestation_api, AttestationApi.Repo,
  username: {:system, "DB_USER"},
  password: {:system, "DB_PASSWORD"},
  database: {:system, "DB_NAME"},
  hostname: {:system, "DB_HOST"},
  port: {:system, "DB_PORT"},
  timeout: 15_000,
  pool_timeout: 15_000,
  ownership_timeout: 15_000,
  pool_size: {:system, :integer, "DB_POOL_SIZE"},
  parameters: [application_name: "AttestationApi", statement_timeout: "5000"],
  loggers: [{Ecto.LoggerJSON, :log, [:info]}]

config :attestation_api, AttestationApi.Clients.Veriffme,
  api_url: {:system, "VERIFFME_API_URL"},
  auth_client: {:system, "VERIFFME_AUTH_CLIENT"},
  api_secret: {:system, "VERIFFME_API_SECRET"}

config :attestation_api, AttestationApi.Clients.Push, push_url: {:system, "PUSH_URL"}

config :ecto_logger_json, truncate_params: true

config :logger, level: :info
