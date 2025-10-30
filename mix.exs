defmodule LibraryApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :library_api,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {LibraryApi.Application, []}
    ]
  end

  defp deps do
    [
      {:dotenvy, "~> 0.8.0"},
      # Phoenix Framework para API REST
      {:phoenix, "~> 1.7.10"},
      {:phoenix_ecto, "~> 4.4"},
      {:plug_cowboy, "~> 2.6"},

      # Bancos de dados
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:mongodb_driver, "~> 1.1"},

      # JSON
      {:jason, "~> 1.4"},

      # Testing
      {:ex_machina, "~> 2.7", only: :test}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
