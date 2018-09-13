use Mix.Config

config :attestation_api, AttestationApi.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY"),
  url: [
    host: System.get_env("HOST"),
    port: System.get_env("PORT") |> Integer.parse |> Kernel.elem(0)
  ],
  http: [port: System.get_env("PORT") |> Integer.parse |> Kernel.elem(0)],
  load_from_system_env: true,
  debug_errors: false,
  catch_errors: true,
  code_reloader: false

config :attestation_api, AttestationApi.Repo,
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASSWORD"),
  database: System.get_env("DB_NAME"),
  hostname: System.get_env("DB_HOST"),
  port: "5432",
  timeout: 15_000,
  pool_timeout: 15_000,
  ownership_timeout: 15_000,
  pool_size: System.get_env("DB_POOL_SIZE") |> Integer.parse |> Kernel.elem(0),
  parameters: [application_name: "AttestationApi", statement_timeout: "5000"],
  loggers: [{Ecto.LoggerJSON, :log, [:info]}]

config :attestation_api,
  veriff_api_url: System.get_env("VERIFFME_API_URL"),
  veriff_auth_client: System.get_env("VERIFFME_AUTH_CLIENT"),
  veriff_api_secret: System.get_env("VERIFFME_API_SECRET")

config :attestation_api, 
  push_url: System.get_env("PUSH_URL")

config :ecto_logger_json, truncate_params: true

config :logger, level: :info
