use Mix.Config

config :quorum,
  context_storage_address: "0x878a8d7915eefb13a26e10962b4a0096f385bfe8", # deployedConfig -> deployedContracts -> kimlicContextStorageAddress
  kimlic_ap_address: "0xe5d723246c020659215ac3154966cb797c24cbaf", # partiesConfig -> createdParties -> kimlic -> address
  kimlic_ap_password: "", # partiesConfig -> createdParties -> kimlic -> password
  veriff_ap_address: "0x64dcb6f92d1b3b63e41a2d309e7aab4c1dcbaa38", # deployedConfig -> deployedContracts -> veriff -> address
  veriff_ap_password: "", # deployedConfig -> deployedContracts -> veriff -> password
  profile_sync_user_address: "0x969675d3bdf6165ec7d36cb5407dbfe257bc6a6c", # deployedConfig -> accountStorageAdapter -> owner -> accountAddress
  profile_sync_user_password: "cbf8c620-5539-4e1d-b720-796a0e6a3fba" # deployedConfig -> accountStorageAdapter -> owner -> accountPassword

config :task_bunny,
  hosts: [
    default: [connect_options: "amqp://kimlic:kimlic@localhost:5672?heartbeat=30"]
  ]

config :ethereumex, url: "http://23.96.119.190:22000"