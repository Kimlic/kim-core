use Mix.Config

config :mobile_api, namespace: MobileApi

config :mobile_api, MobileApi.Endpoint,
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [view: AttestationApi.ErrorView, accepts: ~w(json)],
  http: [protocol_options: [max_request_line_length: 8192, max_header_value_length: 8192]],
  load_from_system_env: true,
  server: true

config :phoenix, :serve_endpoints, true
config :phoenix, :format_encoders, json: Jason

config :logger, :console,
  format: "$message\n",
  handle_otp_reports: true,
  level: :info

import_config "#{Mix.env()}.exs"
