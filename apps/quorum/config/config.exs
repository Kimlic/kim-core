use Mix.Config

alias Quorum.Jobs.TransactionCreate
alias Quorum.Jobs.TransactionStatus

config :quorum,
  client: Quorum.Ethereumex.HttpClient,
  proxy_client: Quorum.Proxy.Client,
  contract_client: Quorum.Contract

config :ethereumex,
  http_options: [ssl: [{:versions, [:"tlsv1.2"]}], recv_timeout: 30_000, timeout: 30_000]

config :task_bunny,
  quorum_queue: [
    namespace: "kimlic-core.",
    queues: [
      [name: "transaction", jobs: [TransactionCreate], worker: [concurrency: 1]],
      [name: "transaction-status", jobs: [TransactionStatus], worker: [concurrency: 1]]
    ]
  ],
  failure_backend: [Quorum.Loggers.TaskBunny]

config :logger, :console,
  format: "$message\n",
  handle_otp_reports: true,
  level: :info

import_config "#{Mix.env()}.exs"
