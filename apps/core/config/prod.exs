use Mix.Config

config :core, 
  redis_host: "stage-redis.eastus.cloudapp.azure.com", # System.get_env("REDIS_HOST"),
  redis_password: "298ac25d80f31148b377be0ae3c298d3185552ea5beaf983678a3fdfbd673d12" # System.get_env("REDIS_PASSWORD")

config :core, Core.Clients.Mailer,
  region: "eu-west-1",
  access_key: "AKIAIZDB5U6XJYGO4OFQ",
  secret: "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"

config :task_bunny,
  hosts: [
    # default: [connect_options: "#{System.get_env("RABBIT_URI")}"]
    default: [connect_options: "amqp://kimlic:v2re3X7tMP@168.62.189.14:5672?heartbeat=30"]
  ]