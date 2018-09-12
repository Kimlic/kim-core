defmodule Core.MixProject do
  use Mix.Project

  @version "1.1.0"

  def project do
    [
      app: :core,
      version: @version,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Core.Application, []},
      extra_applications: [:sasl, :logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:plug, github: "PharosProduction/plug", override: true},
      {:cowboy, "~> 2.4", [github: "Kimlic/cowboy", override: true, manager: :rebar3]},
      {:redix, ">= 0.0.0"},
      {:ecto, "~> 2.1"},
      {:swoosh, "~> 0.19"},
      {:gen_smtp, "~> 0.12.0"},
      {:ex_twilio, "~> 0.6.0"},
      {:task_bunny, "~> 0.3.2"},
      {:httpoison, "~> 1.2", override: true},
      {:pigeon, "~> 1.2.0"},
      {:kadabra, "~> 0.4.2"},
      {:mox, "~> 0.3", only: :test},

      {:quorum, in_umbrella: true}
    ]
  end
end
