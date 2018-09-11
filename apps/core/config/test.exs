use Mix.Config

config :core, :dependencies,
  messenger: MessengerMock,
  push_sender: PushSenderMock

config :core, Redix, "redis://localhost:6379/1"

config :core, Core.Clients.Mailer, adapter: Swoosh.Adapters.Test

config :core,
  sync_fields: [
    "email",
    "phone",
    "documents.id_card",
    "documents.passport",
    "documents.driver_license",
    "documents.residence_permit_card"
  ]

config :pigeon, :apns,
  apns_default: %{
    cert: {:core, "cert.pem"},
    key: {:core, "key_unencrypted.pem"},
    mode: :dev,
    apns_2197: true
  }

config :task_bunny,
  core_queue: [
    namespace: "core-test.",
    queues: [
      [name: "push_notifications", jobs: Core.Push.Job, worker: false]
    ]
  ]

# Print only warnings and errors during test
config :logger, level: :warn
