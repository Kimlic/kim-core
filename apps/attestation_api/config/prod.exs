use Mix.Config

config :attestation_api, AttestationApi.Endpoint,
  debug_errors: false,
  catch_errors: true,
  code_reloader: false,
  check_origin: false
  
config :attestation_api, AttestationApi.Repo,
  #username: "kimlic@stage-postgresql-ap", # System.get_env("DB_USER"),
  username: "kimlic", # System.get_env("DB_USER"),
  password: "LU6dME4NzQ", # System.get_env("DB_PASSWORD"),
  #hostname: "stage-postgresql-ap.postgres.database.azure.com", # System.get_env("DB_HOST"),
  hostname: "stage-postgresql-ap.eastus.cloudapp.azure.com", # System.get_env("DB_HOST"),
  pool_size: 10, # System.get_env("DB_POOL") |> Integer.parse |> elem(0),
  loggers: [{Ecto.LoggerJSON, :log, [:info]}]

config :attestation_api, push_url: "http://23.96.41.254:4000" # System.get_env("PUSH_URL")
