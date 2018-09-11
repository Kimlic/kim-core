use Mix.Config

config :mobile_api, MobileApi.Endpoint,
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

config :mobile_api,
  rate_limit_create_phone_verification_timeout: {:system, :integer, "RATE_LIMIT_CREATE_PHONE_VERIFICATION_TIMEOUT"},
  rate_limit_create_phone_verification_attempts: {:system, :integer, "RATE_LIMIT_CREATE_PHONE_VERIFICATION_ATTEMPTS"},
  debug_info_enabled: {:system, :boolean, "DEBUG_INFO_ENABLED"}

config :hammer, 
  backend: {
    Hammer.Backend.Redis, [
      expiry_ms: :timer.hours(24) * 7, 
      redix_config: {:system, "REDIS_URI"}
    ]
  }

config :phoenix, :serve_endpoints, true

config :logger, level: :info