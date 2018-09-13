use Mix.Config

config :mobile_api, MobileApi.Endpoint,
  secret_key_base: "84kntMYOcyFTBn7bL0ydvotZ4gDT1nPjwseG+VfCValy9GES2pgI2ir1FQemS/lz",
  http: [port: 4000],
  url: [
    host: "localhost", 
    port: 4000
  ],
  debug_errors: true,
  catch_errors: false,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :mobile_api,
  rate_limit_create_phone_verification_timeout: :timer.hours(24) * 7,
  rate_limit_create_phone_verification_attempts: 5,
  debug_info_enabled: false

config :hammer, 
  backend: {
    Hammer.Backend.Redis, [
      expiry_ms: :timer.hours(24) * 7, 
      redix_config: [
        host: "127.0.0.1", 
        port: 6379, 
        password: nil
      ]
    ]
  }

config :phoenix, :stacktrace_depth, 20