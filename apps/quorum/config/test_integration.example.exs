use Mix.Config

config :quorum,
  client: Quorum.Ethereumex.HttpClient,
  proxy_client: Quorum.Proxy.Client,
  contract_client: Quorum.Contract,
  context_storage_address: "",
  kimlic_ap_address: "",
  kimlic_ap_password: "kimlicp@ssw0rd",
  veriff_ap_address: "",
  veriff_ap_password: "veriffp@ssw0rd",
  profile_sync_user_address: "",
  profile_sync_user_password: "",
  relying_party_address: "",
  relying_party_password: "firstRelyingPartyp@ssw0rd"

config :task_bunny,
  quorum_queue: [
    namespace: "kimlic-core-test.",
    queues: [
      [name: "transaction", jobs: [Quorum.Jobs.TransactionCreate], worker: [concurrency: 1]],
      [name: "transaction-status", jobs: [Quorum.Jobs.TransactionStatus], worker: [concurrency: 1]]
    ]
  ]
