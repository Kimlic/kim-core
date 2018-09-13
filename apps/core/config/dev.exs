use Mix.Config

config :core, 
  redis_host: "127.0.0.1",
  redis_port: 6379,
  redis_password: nil

config :core,
  verifications_ttl_email: 24 * 60 * 60,
  verifications_ttl_phone: 24 * 60 * 60

config :core, :emails,
  create_profile_email: %{
    from_email: "verification@kimlic.com",
    from_name: "Kimlic",
    subject: "Kimlic - New user email verification"
  }

config :core, messenger_message_from: "Kimlic"

config :core, Core.Clients.Mailer, adapter: Swoosh.Adapters.Local
# config :core, Core.Clients.Mailer,
#   adapter: Swoosh.Adapters.AmazonSES,
#   region: "eu-west-1",
#   access_key: "AKIAJXIR6LE2FNZFBTFA",
#   secret: "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"

config :task_bunny,
  hosts: [
    default: [connect_options: "amqp://kimlic:kimlic@localhost:5672?heartbeat=30"]
  ]

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
    mode: :dev
  }

config :pigeon, :fcm,
  fcm_default: %{
    key: "AAAAvbQPkNc:APA91bFh0gtzNbOEue789EMFX_kYsaE1UVvDa7V7GXKdxTBDptyxfXREnPtIuaaatb15xXQlvwaw08Kl0aeCGQ8j5i6kXpbLtdgdSoz1ck8_FFL0Zz5NeRXz0OyCxXnn-_i8xPfsD5oB2EhxOTasiQfUzhVsFRs68w",
    mode: :dev
  }

config :ex_twilio,
  account_sid: "AC07bf3306b3acf8fe318a5f60ec24466f",
  auth_token: "a4cb70766ad8b8bfbe47fe4f6bce0f22"

config :logger, :console, format: "[$level] $message\n"