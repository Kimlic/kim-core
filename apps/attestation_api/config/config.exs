use Mix.Config

config :attestation_api, namespace: AttestationApi

config :attestation_api, AttestationApi.Endpoint,
  secret_key_base: "84kntMYOcyFTBn7bL0ydvotZ4gDT1nPjwseG+VfCValy9GES2pgI2ir1FQemS/lz",
  http: [port: 4001],
  url: [
    host: "localhost",
    port: 4001
  ],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [view: AttestationApi.ErrorView, accepts: ~w(json)],
  http: [protocol_options: [max_request_line_length: 8192, max_header_value_length: 8192]],
  server: true,
  watchers: []

config :attestation_api, AttestationApi.Repo,
  database: "ap_server",
  port: "5432",
  timeout: 30_000,
  pool_timeout: 30_000,
  ownership_timeout: 30_000
  # parameters: [application_name: "AttestationApi", statement_timeout: "180_000"]
  
config :attestation_api,
  veriff_api_url: "https://api.veriff.me/v1",
  veriff_auth_client: "0fcc03f9-3142-41e5-8dab-94bf3964eae8",
  veriff_api_secret: "2061049f-e9c4-48fa-8021-a4ab99d1ec65"

config :attestation_api, ecto_repos: [AttestationApi.Repo]

config :attestation_api, :dependencies,
  veriffme: AttestationApi.Clients.Veriffme,
  push: AttestationApi.Clients.Push

config :phoenix, :serve_endpoints, true
config :phoenix, :format_encoders, json: Jason

import_config "#{Mix.env()}.exs"
