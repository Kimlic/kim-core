use Mix.Config

config :core, 
  redis_host: "stage-kimlic.redis.cache.windows.net", # System.get_env("REDIS_HOST"),
  redis_password: "NxCFs4gNxvbga51ySs0gQokCBTve1JBXmMoJtIj4Dxo=" # System.get_env("REDIS_PASSWORD")

config :core, Core.Clients.Mailer,
  adapter: Swoosh.Adapters.AmazonSES,
  region: "eu-west-1",
  access_key: "AKIAJLNAMPLSK62TWHBA",
  secret: "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"

config :task_bunny,
  hosts: [
    # default: [connect_options: "#{System.get_env("RABBIT_URI")}"]
    default: [connect_options: "amqp://kimlic:v2re3X7tMP@168.62.189.14:5672?heartbeat=30"]
  ]