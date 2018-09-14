use Mix.Config

backends = [
  :console,
]

config :logger,
  format: "[$date] [$time] [$level] $metadata $message\n",
  utc_log: true,
  backends: backends

config :logger, :console,
  level: :debug,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :application, :module, :function, :crash_reason],
  handle_otp_reports: false,
  handle_sasl_reports: false