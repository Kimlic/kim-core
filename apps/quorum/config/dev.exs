use Mix.Config

config :quorum,
  context_storage_address: {:system, "CONTEXT_STORAGE_ADDRESS"},
  kimlic_ap_address: {:system, "KIMLIC_AP_ADDRESS"},
  kimlic_ap_password: "kimlicp@ssw0rd",
  veriff_ap_address: {:system, "VERIFF_AP_ADDRESS"},
  veriff_ap_password: "veriffp@ssw0rd",
  profile_sync_user_address: {:system, "PROFILE_SYNC_USER_ADDRESS"},
  profile_sync_user_password: "firstRelyingPartyp@ssw0rd",
  gas: "0x1e8480",
  allowed_rpc_methods: [
    "web3_clientVersion",
    "eth_call",
    "eth_sendTransaction",
    "eth_sendRawTransaction",
    "eth_getTransactionCount",
    "getTransactionReceipt",
    "personal_newAccount",
    "personal_unlockAccount"
  ]

config :task_bunny,
  hosts: [
    default: [connect_options: "amqp://localhost?heartbeat=30"]
  ]

config :ethereumex, url: "http://127.0.0.1:22000"