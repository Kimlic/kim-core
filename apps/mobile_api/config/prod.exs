use Mix.Config

config :mobile_api, MobileApi.Endpoint,
  debug_errors: false,
  catch_errors: true,
  code_reloader: false,
  check_origin: false

config :mobile_api, debug_info_enabled: false

config :hammer, 
  backend: {
    Hammer.Backend.ETS, [
      expiry_ms: :timer.hours(24) * 7
    ]
  }