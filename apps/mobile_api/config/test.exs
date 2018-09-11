use Mix.Config

config :mobile_api, MobileApi.Endpoint,
  http: [port: 4001],
  server: false

config :hammer,
  backend: {Hammer.Backend.Redis, [expiry_ms: :timer.hours(24) * 7, redix_config: "redis://localhost:6379/1"]}

config :mobile_api, rate_limit_create_phone_verification_attempts: 5

config :mobile_api, debug_info_enabled: true

config :logger, level: :warn
