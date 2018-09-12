use Mix.Config

config :core, 
  redis_host: System.get_env("REDIS_HOST"),
  redis_port: System.get_env("REDIS_PORT") |> Integer.parse! |> Kernel.elem(0),
  redis_password: System.get_env("REDIS_PASSWORD")

config :core,
  verifications_ttl: [
    email: System.get_env("VERIFICATION_EMAIL_TTL"),
    phone: System.get_env("VERIFICATION_PHONE_TTL")
  ]

config :core, :emails,
  create_profile_email: %{
    from_email: System.get_env("EMAIL_CREATE_PROFILE_FROM_EMAIL"),
    from_name: System.get_env("EMAIL_CREATE_PROFILE_FROM_NAME"),
    subject: System.get_env("EMAIL_CREATE_PROFILE_SUBJECT")
  }

config :core, messenger_message_from: System.get_env("MESSENGER_MESSAGE_FROM")

config :core, Core.Clients.Mailer,
  adapter: Swoosh.Adapters.AmazonSES,
  region: System.get_env("AMAZON_SES_REGION_ENDPOINT"),
  access_key: System.get_env("AMAZON_SES_ACCESS_KEY"),
  secret: System.get_env("AMAZON_SES_SECRET_KEY")

config :task_bunny,
  hosts: [
    default: [connect_options: System.get_env("RABBIT_URI")]
  ]

config :core, sync_fields: System.get_env("SYNC_VERIFICATIONS")

config :pigeon, :apns,
  apns_default: %{
    cert: System.get_env("PIGEON_APNS_CERT"),
    key: System.get_env("PIGEON_APNS_CERT_UNENCRYPTED"),
    mode: :prod
  }

config :pigeon, :fcm,
  fcm_default: %{
    key: System.get_env("PIGEON_FCM_KEY"),
    mode: :prod
  }

config :ex_twilio,
  account_sid: System.get_env("TWILIO_ACCOUNT_SID"),
  auth_token: System.get_env("TWILIO_AUTH_TOKEN")

config :logger, level: :info