use Mix.Config

config :quorum,
  context_storage_address: "0xd3683825a75852455fe69f206cba18dbf9afd8d2", # deployedConfig -> deployedContracts -> kimlicContextStorageAddress
  kimlic_ap_address: "0x8de4bdeddddc58be3d5944cb05f63c8b492fecca", # partiesConfig -> createdParties -> kimlic -> address
  kimlic_ap_password: "", # partiesConfig -> createdParties -> kimlic -> password
  veriff_ap_address: "0xc3893fdf1b5ba17d1ec2ea23600f33d316272caf", # deployedConfig -> deployedContracts -> veriff -> address
  veriff_ap_password: "", # deployedConfig -> deployedContracts -> veriff -> password
  profile_sync_user_address: "0x1eea498f6e56b53a58c50f1dd9870e358760b9ec", # deployedConfig -> accountStorageAdapter -> owner -> accountAddress
  profile_sync_user_password: "78db4170-0176-4f9c-b907-0db10ad2de7f", # deployedConfig -> accountStorageAdapter -> owner -> accountPassword
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