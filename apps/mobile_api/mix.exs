defmodule MobileApi.Mixfile do
  use Mix.Project

  @version "1.1.0"

  def project do
    [
      app: :mobile_api,
      version: @version,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      deps: deps()
    ]
  end

  def application do
    [
      mod: {MobileApi.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:jason, "~> 1.0"},
      {:phoenix, github: "Kimlic/phoenix", override: true},
      {:plug, github: "Kimlic/plug", override: true},
      {:eview, "~> 0.12"},
      {:plug_logger_json, "~> 0.5"},
      {:cowboy, "~> 2.4", [github: "Kimlic/cowboy", override: true, manager: :rebar3]},
      {:hammer, "~> 5.0"},
      {:hammer_backend_redis, "~> 5.0"},
      {:quixir, "~> 0.9", only: :test},

      {:core, in_umbrella: true},
      {:quorum, in_umbrella: true}
    ]
  end
end
