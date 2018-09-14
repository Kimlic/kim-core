use Mix.Config

config :core, 
  redis_host: System.get_env("REDIS_HOST"),
  redis_password: System.get_env("REDIS_PASSWORD")

config :core, Core.Clients.Mailer,
  adapter: Swoosh.Adapters.AmazonSES,
  region: "eu-west-1",
  access_key: "AKIAJXIR6LE2FNZFBTFA",
  secret: "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"

config :task_bunny,
  hosts: [
    default: [connect_options: "#{System.get_env("RABBIT_URI")}"]
  ]