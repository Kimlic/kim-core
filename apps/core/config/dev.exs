use Mix.Config

config :core, 
  redis_host: "127.0.0.1",
  redis_password: nil

config :core, Core.Clients.Mailer, adapter: Swoosh.Adapters.Local

config :task_bunny,
  hosts: [
    default: [connect_options: "amqp://kimlic:kimlic@localhost:5672?heartbeat=30"]
  ]