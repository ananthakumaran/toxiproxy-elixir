defmodule Toxiproxy.Mixfile do
  use Mix.Project

  def project do
    [app: :toxiproxy,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:tesla, "~> 0.6.0"},
      {:poison, ">= 1.0.0"},
      {:hackney, "1.6.5", only: :test},
      {:mix_test_watch, "~> 0.3", only: :dev}
    ]
  end
end
