use Mix.Config

config :quorum,
  context_storage_address: "0x2df4143c5f976eb9d2cff8f7c3d8af13e551daf5",
  kimlic_ap_address: "0x2d53b00ed1a56437b19adc4e6192c6d1b78f708c",
  kimlic_ap_password: "",
  veriff_ap_address: "0x4ff6e73edbb1fd166d69ad65950d99b29f447421",
  veriff_ap_password: "",
  profile_sync_user_address: "0xf4e9d429636991e57f0c15a15f0708456c379db1", # deployedConfig -> accountStorageAdapter -> owner -> accountAddress
  profile_sync_user_password: "7c709482-d32e-4d7a-ad85-3ebaa3a3435c", # deployedConfig -> accountStorageAdapter -> owner -> accountPassword
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
    default: [connect_options: "amqp://kimlic:kimlic@localhost:5672?heartbeat=30"]
  ]

config :ethereumex, url: "http://127.0.0.1:22000"