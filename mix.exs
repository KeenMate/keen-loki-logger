defmodule LokiLogger.MixProject do
  use Mix.Project

  def project do
    [
      app: :keen_loki_logger,
      version: "0.5.1",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Keen Loki Logger",
      source_url: "https://github.com/KeenMate/elixir-loki-logger.git"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4.0"},
      {:ex_doc, "~> 0.31.2", only: :dev},
      {:benchee, "~> 1.1.0", only: :test},
      {:tesla, "~> 1.8.0"},
      {:finch, "~> 0.17"},
      {:protobuf, "~> 0.15.0"},
      {:snappyer, "~> 1.2.8"}
    ]
  end

  defp description() do
    "Elixir Logger Backend for Grafana Loki - based on original loki_logger, which is dead since 2019, but enhanced from multiple forks and with plan to develop it further"
  end

  defp package() do
    [
      name: "keen_loki_logger",
      # organization: "keenmate",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/KeenMate/elixir-loki-logger.git"}
    ]
  end
end
