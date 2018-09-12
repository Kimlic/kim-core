use Mix.Config

config :core, Redix, {:system, "REDIS_URI"}

config :core,
  verifications_ttl: [
    email: System.get_env("VERIFICATION_EMAIL_TTL"),
    phone: System.get_env("VERIFICATION_PHONE_TTL")
  ]

config :core, :emails,
  create_profile_email: %{
    from_email: {:system, "EMAIL_CREATE_PROFILE_FROM_EMAIL"},
    from_name: {:system, "EMAIL_CREATE_PROFILE_FROM_NAME"},
    subject: {:system, "EMAIL_CREATE_PROFILE_SUBJECT"}
  }

config :core, messenger_message_from: {:system, "MESSENGER_MESSAGE_FROM"}

config :core, Core.Clients.Mailer,
  adapter: Swoosh.Adapters.AmazonSES,
  region: {:system, "AMAZON_SES_REGION_ENDPOINT"},
  access_key: {:system, "AMAZON_SES_ACCESS_KEY"},
  secret: {:system, "AMAZON_SES_SECRET_KEY"}

config :task_bunny,
  hosts: [
    default: [connect_options: System.get_env("RABBIT_URI")]
  ]

config :core, sync_fields: {:system, :list, "SYNC_VERIFICATIONS"}

config :pigeon, :apns,
  apns_default: %{
    cert: {:system, "PIGEON_APNS_CERT"},
    key: {:system, "PIGEON_APNS_CERT_UNENCRYPTED"},
    mode: :prod
  }

config :pigeon, :fcm,
  fcm_default: %{
    key: {:system, "PIGEON_FCM_KEY"},
    mode: :prod
  }

config :ex_twilio,
  account_sid: {:system, "TWILIO_ACCOUNT_SID"},
  auth_token: {:system, "TWILIO_AUTH_TOKEN"}

config :logger, level: :info