defmodule InfinityAPS.Mixfile do
  use Mix.Project

  def project do
    [
      app: :aps,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {InfinityAPS.Application, []}
    ]
  end

  defp aliases do
    ["compile": "compile --warnings-as-errors"]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:pummpcomm, "~> 2.5.1"},
      {:twilight_informant, github: "infinity-aps/twilight_informant", branch: "infinity_aps_integration"},
      {:poison, "~> 3.1"},
      {:timex, "~> 3.0"},
      {:cfg, path: "../cfg"}
    ]
  end
end