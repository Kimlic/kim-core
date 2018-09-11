defmodule Quorum.MixProject do
  use Mix.Project

  @version "1.1.0"

  def project do
    [
      app: :quorum,
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
      mod: {Quorum.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:confex, "~> 3.3.1"},
      {:ethereumex, "~> 0.3.2"},
      {:httpoison, "~> 1.2", override: true},
      {:jason, "~> 1.0"},
      {:keccakf1600, "~> 2.0.0", hex: :keccakf1600_orig},
      {:task_bunny, "~> 0.3.2"},
      {:uuid, "~> 1.1"},
      {:mox, "~> 0.3", only: :test}
    ]
  end
end
