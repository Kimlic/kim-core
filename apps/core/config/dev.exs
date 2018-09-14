use Mix.Config

config :core, 
  redis_host: "127.0.0.1",
  redis_password: nil

# config :core, Core.Clients.Mailer, adapter: Swoosh.Adapters.Local
config :core, Core.Clients.Mailer,
  region: "eu-west-1",
  access_key: "AKIAIZDB5U6XJYGO4OFQ",
  secret: "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"
  
config :task_bunny,
  hosts: [
    default: [connect_options: "amqp://kimlic:kimlic@localhost:5672?heartbeat=30"]
  ]