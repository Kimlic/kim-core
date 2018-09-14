use Mix.Config


backends = [
  :console
  # {Uberlog.File, :ecto},
  # {Uberlog.File, :error},
  # {Uberlog.File, :request},
  # {Uberlog.File, :phoenix},
  # {Uberlog.File, :absinthe},
  # {Uberlog.File, :rp_mobile},
  # {Uberlog.File, :rp_dashboard},
  # {Uberlog.Telegram, :telegram_warn},
  # {Uberlog.Telegram, :telegram_error},
  # {Uberlog.Slack.Logger, [:warn, :error]},
  # Uberlog.Graylog.Tcp
]

config :logger,
  format: "[$date] [$time] [$level] $metadata $message\n",
  utc_log: true,
  backends: backends

# config :uberlog, :slack,
#   url: "https://hooks.slack.com/services/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"

# config :logger, Uberlog.Graylog.Tcp,
#   host: "40.115.118.108",
#   port: 12201,
#   level: :debug,
#   include_timestamp: true,
#   override_host: false,
#   metadata: [:request_id, :application, :module, :function, :crash_reason],
#   handle_otp_reports: true,
#   handle_sasl_reports: true

# config :logger, :telegram_warn,
#   level: :warn,
#   format: "[$date] [$time] [$level] $metadata $message\n",
#   metadata: [:request_id, :application, :module, :function, :crash_reason],
#   chat_id: "@kimlic_rp_logs",
#   token: "630258546:AAHl1WdIvVrBjzDx8DcqUlHh6p1mqH3Efr0",
#   handle_otp_reports: false,
#   handle_sasl_reports: false

# config :logger, :telegram_error,
#   level: :error,
#   format: "[$date] [$time] [$level] $metadata $message\n",
#   metadata: [:request_id, :application, :module, :function, :crash_reason],
#   chat_id: "@kimlic_rp_logs",
#   token: "630258546:AAHl1WdIvVrBjzDx8DcqUlHh6p1mqH3Efr0",
#   handle_otp_reports: false,
#   handle_sasl_reports: false

config :logger, :console,
  level: :debug,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :application, :module, :function, :crash_reason],
  colors: [enable: true, debug: :green],
  handle_otp_reports: false,
  handle_sasl_reports: false

# config :logger, :error,
#   level: :error,
#   path: Path.expand("./logs/error.log"),
#   metadata: [:channel, :application, :module, :function, :crash_reason],
#   rotate: %{period: :date, keep: 30},
#   handle_otp_reports: true,
#   handle_sasl_reports: true

# config :logger, :request,
#   level: :debug,
#   path: Path.expand("./logs/request.log"),
#   metadata: [:request_id, :application, :module, :function, :crash_reason],
#   metadata_filter: [application: :plug],
#   rotate: %{period: :date, keep: 20},
#   handle_otp_reports: true,
#   handle_sasl_reports: true

# config :logger, :ecto,
#   level: :debug,
#   path: Path.expand("./logs/ecto.log"),
#   metadata: [:request_id, :application, :module, :function, :crash_reason],
#   metadata_filter: [application: :ecto],
#   rotate: %{period: :date, keep: 10},
#   handle_otp_reports: true,
#   handle_sasl_reports: true

# config :logger, :phoenix,
#   level: :debug,
#   path: Path.expand("./logs/phoenix.log"),
#   metadata: [:request_id, :application, :module, :function, :crash_reason],
#   metadata_filter: [application: :phoenix],
#   rotate: %{period: :date, keep: 20},
#   handle_otp_reports: true,
#   handle_sasl_reports: true

# config :logger, :absinthe,
#   level: :debug,
#   path: Path.expand("./logs/absinthe.log"),
#   metadata: [:request_id, :application, :module, :function, :crash_reason],
#   metadata_filter: [application: :absinthe],
#   rotate: %{period: :date, keep: 20},
#   handle_otp_reports: true,
#   handle_sasl_reports: true

# config :logger, :rp_mobile,
#   level: :debug,
#   path: Path.expand("./logs/rp_mobile.log"),
#   metadata: [:request_id, :application, :module, :function, :crash_reason],
#   metadata_filter: [channel: :rp_mobile],
#   rotate: %{period: :date, keep: 10},
#   handle_otp_reports: true,
#   handle_sasl_reports: true

# config :logger, :rp_dashboard,
#   level: :debug,
#   path: Path.expand("./logs/rp_dashboard.log"),
#   metadata: [:request_id, :application, :module, :function, :crash_reason],
#   metadata_filter: [channel: :rp_dashboard],
#   rotate: %{period: :date, keep: 10},
#   handle_otp_reports: true,
#   handle_sasl_reports: true