defmodule AttestationApi.Mixfile do
  use Mix.Project

  @version "1.1.0"

  def project do
    [
      app: :attestation_api,
      version: @version,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {AttestationApi.Application, []},
      extra_applications: [:sasl, :logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, github: "Kimlic/phoenix", override: true},
      {:plug, github: "Kimlic/plug", override: true},
      {:cowboy, "~> 2.4", [github: "Kimlic/cowboy", override: true, manager: :rebar3]},
      {:phoenix_pubsub, "~> 1.0"},
      {:httpoison, "~> 1.2", override: true},
      {:jason, "~> 1.0"},
      {:plug_logger_json, "~> 0.5"},
      {:ecto, "~> 2.2"},
      {:postgrex, "~> 0.13"},
      {:eview, "~> 0.12"},
      {:ecto_logger_json, git: "https://github.com/edenlabllc/ecto_logger_json.git", branch: "truncate-params-option"},
      {:mox, "~> 0.3", only: :test},
      {:ex_machina, "~> 2.2", only: :test},

      {:quorum, in_umbrella: true}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
