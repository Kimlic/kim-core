use Mix.Config

config :quorum,
  context_storage_address: "0x1c5c5721000e2d5910ed4cbb17646bfa3b0c278c", # System.get_env("CONTEXT_STORAGE_ADDRESS"),
  kimlic_ap_address: "0x1adfcf314697db1f0561676cabd3a0517a63e954", # System.get_env("KIMLIC_AP_ADDRESS"),
  kimlic_ap_password: "", # System.get_env("KIMLIC_AP_PASSWORD"),
  veriff_ap_address: "0x4aabc1c45ff64c562209d2207617f632184649a1", # System.get_env("VERIFF_AP_ADDRESS"),
  veriff_ap_password: "", # System.get_env("VERIFF_AP_PASSWORD"),
  profile_sync_user_address: "0x8ac47c376b2b0033ec8b085f50e1b124d1ac25c0", # System.get_env("PROFILE_SYNC_USER_ADDRESS"),
  profile_sync_user_password: "69a36acb-aa1d-4897-8f71-57f452bfeae2" # System.get_env("PROFILE_SYNC_USER_PASSWORD")

config :task_bunny,
  hosts: [
    # default: [connect_options: "#{System.get_env("RABBIT_URI")}"]
    default: [connect_options: "amqp://kimlic:v2re3X7tMP@168.62.189.14:5672?heartbeat=30"]
  ]

config :ethereumex, url: "http://137.135.110.105:22000" # System.get_env("QUORUM_URI")
