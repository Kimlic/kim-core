use Mix.Config

config :mobile_api, MobileApi.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY"),
  http: [port: System.get_env("PORT") |> Integer.parse |> Kernel.elem(0)],
  url: [
    host: System.get_env("HOST"),
    port: System.get_env("PORT") |> Integer.parse |> Kernel.elem(0)
  ],
  load_from_system_env: true,
  debug_errors: false,
  catch_errors: true,
  code_reloader: false

config :mobile_api,
  rate_limit_create_phone_verification_timeout: System.get_env("RATE_LIMIT_CREATE_PHONE_VERIFICATION_TIMEOUT"),
  rate_limit_create_phone_verification_attempts: System.get_env("RATE_LIMIT_CREATE_PHONE_VERIFICATION_ATTEMPTS"),
  debug_info_enabled: System.get_env("DEBUG_INFO_ENABLED")

config :hammer, 
  backend: {
    Hammer.Backend.Redis, [
      expiry_ms: :timer.hours(24) * 7, 
      redix_config: [
        host: System.get_env("REDIS_HOST"), 
        port: System.get_env("REDIS_PORT") |> Integer.parse |> Kernel.elem(0), 
        password: System.get_env("REDIS_PASSWORD")
      ]
    ]
  }

config :phoenix, :serve_endpoints, true

config :logger, level: :info