use Mix.Config

config :core, :dependencies,
  messenger: Core.Clients.Messenger,
  push_sender: Core.Push.PushSender

config :task_bunny,
  core_queue: [
    namespace: "core.",
    queues: [
      [name: "push_notifications", jobs: Core.Push.Job, worker: [concurrency: 1]]
    ]
  ],
  failure_backend: [Quorum.Loggers.TaskBunny]

config :logger, :console,
  format: "$message\n",
  handle_otp_reports: true,
  level: :info

import_config "#{Mix.env()}.exs"
