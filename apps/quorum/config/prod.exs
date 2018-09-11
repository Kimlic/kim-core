use Mix.Config

config :quorum,
  context_storage_address: {:system, "CONTEXT_STORAGE_ADDRESS"},
  kimlic_ap_address: {:system, "KIMLIC_AP_ADDRESS"},
  kimlic_ap_password: {:system, "KIMLIC_AP_PASSWORD"},
  veriff_ap_address: {:system, "VERIFF_AP_ADDRESS"},
  veriff_ap_password: {:system, "VERIFF_AP_PASSWORD"},
  profile_sync_user_address: {:system, "PROFILE_SYNC_USER_ADDRESS"},
  profile_sync_user_password: {:system, "PROFILE_SYNC_USER_PASSWORD"},
  gas: {:system, "QUORUM_GAS"},
  allowed_rpc_methods: {:system, :list, "QUORUM_ALLOWED_RPC_METHODS"}

config :task_bunny,
  hosts: [
    default: [connect_options: {:system, "RABBIT_URI"}]
  ]

config :ethereumex, url: {:system, "QUORUM_URI"}
