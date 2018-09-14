use Mix.Config

config :mobile_api, MobileApi.Endpoint,
  debug_errors: false,
  catch_errors: true,
  code_reloader: true,
  check_origin: false

config :mobile_api, debug_info_enabled: true

config :hammer, 
  backend: {
    Hammer.Backend.ETS, [
      expiry_ms: :timer.hours(24) * 7
    ]
  }

config :phoenix, :stacktrace_depth, 20