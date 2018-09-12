use Mix.Config

config :quorum,
  context_storage_address: System.get_env("CONTEXT_STORAGE_ADDRESS"),
  kimlic_ap_address: System.get_env("KIMLIC_AP_ADDRESS"),
  kimlic_ap_password: System.get_env("KIMLIC_AP_PASSWORD"),
  veriff_ap_address: System.get_env("VERIFF_AP_ADDRESS"),
  veriff_ap_password: System.get_env("VERIFF_AP_PASSWORD"),
  profile_sync_user_address: System.get_env("PROFILE_SYNC_USER_ADDRESS"),
  profile_sync_user_password: System.get_env("PROFILE_SYNC_USER_PASSWORD"),
  gas: System.get_env("QUORUM_GAS"),
  allowed_rpc_methods: System.get_env("QUORUM_ALLOWED_RPC_METHODS")

config :task_bunny,
  hosts: [
    default: [connect_options: System.get_env("RABBIT_URI")]
  ]

config :ethereumex, url: System.get_env("QUORUM_URI")
