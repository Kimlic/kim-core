use Mix.Config

config :attestation_api, namespace: AttestationApi

config :attestation_api, AttestationApi.Endpoint,
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [view: AttestationApi.ErrorView, accepts: ~w(json)],
  http: [protocol_options: [max_request_line_length: 8192, max_header_value_length: 8192]],
  load_from_system_env: true,
  server: true

config :attestation_api, ecto_repos: [AttestationApi.Repo]

config :attestation_api, :dependencies,
  veriffme: AttestationApi.Clients.Veriffme,
  push: AttestationApi.Clients.Push

config :phoenix, :serve_endpoints, true
config :phoenix, :format_encoders, json: Jason

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

import_config "#{Mix.env()}.exs"
