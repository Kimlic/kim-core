use Mix.Config

config :attestation_api, AttestationApi.Endpoint,
  http: [port: 4001],
  server: false

config :attestation_api, :dependencies,
  veriffme: VeriffmeMock,
  push: AttestationApiPushMock

config :attestation_api, AttestationApi.Repo,
  username: "postgres",
  password: "postgres",
  database: "attestation_api_test",
  hostname: "localhost",
  port: "5432",
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :warn
