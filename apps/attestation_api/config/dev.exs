use Mix.Config

config :attestation_api, AttestationApi.Endpoint,
  secret_key_base: "84kntMYOcyFTBn7bL0ydvotZ4gDT1nPjwseG+VfCValy9GES2pgI2ir1FQemS/lz",
  url: [
    host: "localhost", 
    port: 4001
  ],
  http: [port: 4001],
  debug_errors: true,
  catch_errors: false,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :attestation_api, AttestationApi.Repo,
  username: "kimlic",
  password: "kimlic",
  database: "attestation_api_dev",
  hostname: "localhost",
  port: "5432",
  timeout: 15_000,
  pool_timeout: 15_000,
  ownership_timeout: 15_000,
  pool_size: 10,
  parameters: [application_name: "AttestationApi", statement_timeout: "5000"]

config :attestation_api, AttestationApi.Clients.Veriffme,
  api_url: "https://api.veriff.me/v1",
  auth_client: "35313dad-da0c-4d15-b63e-e8ce2136a729",
  api_secret: "ca9955ad-38e4-4fea-838c-d1aeb4e4149c"

config :attestation_api, AttestationApi.Clients.Push, push_url: "http://127.0.0.1"

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
