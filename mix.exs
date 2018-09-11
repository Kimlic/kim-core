defmodule Kimlic.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      name: "Kimlic",
      apps_path: "apps",
      version: "1.0.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      source_url: "https://github.com/Kimlic/kimlic-elixir",
      docs: [
        output: "./docs",
        extras: ["README.md", "ENVIRONMENT.md"]
      ]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.18.0", only: [:dev, :test], runtime: false},
      {:distillery, "~> 1.5", runtime: false},
      {:excoveralls, "~> 0.9", only: [:dev, :test]},
      {:credo, "~> 0.10", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.drop", "ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
