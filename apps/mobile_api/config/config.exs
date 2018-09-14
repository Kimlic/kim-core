use Mix.Config

config :mobile_api, namespace: MobileApi

config :mobile_api, MobileApi.Endpoint,
  secret_key_base: "84kntMYOcyFTBn7bL0ydvotZ4gDT1nPjwseG+VfCValy9GES2pgI2ir1FQemS/lz",
  http: [port: 4000],
  url: [
    host: "localhost", 
    port: 4000
  ],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [view: AttestationApi.ErrorView, accepts: ~w(json)],
  http: [protocol_options: [max_request_line_length: 8192, max_header_value_length: 8192]],
  server: true,
  watchers: []

config :mobile_api,
  rate_limit_create_phone_verification_timeout: :timer.hours(24) * 7,
  rate_limit_create_phone_verification_attempts: 5

config :phoenix, :serve_endpoints, true
config :phoenix, :format_encoders, json: Jason

import_config "#{Mix.env()}.exs"
