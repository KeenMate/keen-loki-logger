defmodule LokiLogger.MixProject do
  use Mix.Project

  def project do
    [
      app: :loki_logger,
      version: "0.3.1",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "Loki Logger",
      source_url: "https://github.com/wardbekker/LokiLogger.git"
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
      {:httpoison, "~> 2.1"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:benchee, "~> 1.1.0", only: :test},
      {:tesla, "~> 1.8.0"},
      {:finch, "~> 0.17"},
      {:protobuf, "~> 0.10.0"},
      {:google_protos, "~> 0.3.0"},
      {:snappyer, "~> 1.2.8"},
    ]
  end

  defp description() do
    "Elixir Logger Backend for Grafana Loki"
  end

  defp package() do
    [
      name: "loki_logger",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/wardbekker/LokiLogger.git"}
    ]
  end
end
