use Mix.Config

config :mobile_api, MobileApi.Endpoint,
  http: [port: 4001],
  server: false

config :hammer,
  backend: {
    Hammer.Backend.Redis, 
    [
      expiry_ms: :timer.hours(24) * 7, 
      redix_config: [
        host: "kimcore.redis.cache.windows.net", 
        port: 6379, 
        password: "seLjCUSJ72naqfwYQvBg1jbORvjtsRKVnAY6RrAUEmA="
      ]
    ]
  }

config :mobile_api, rate_limit_create_phone_verification_attempts: 5

config :mobile_api, debug_info_enabled: true

config :logger, level: :warn
