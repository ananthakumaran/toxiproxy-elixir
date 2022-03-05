defmodule Toxiproxy.Mixfile do
  use Mix.Project

  @version "0.6.0"

  def project do
    [
      app: :toxiproxy,
      version: @version,
      elixir: "~> 1.10",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: "Toxiproxy client",
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:tesla, "~> 1.0"},
      {:poison, ">= 1.0.0"},
      {:hackney, "1.6.5", only: :test},
      {:mix_test_watch, "~> 0.3", only: :dev},
      {:ex_doc, "~> 0.19", only: :dev}
    ]
  end

  defp package do
    %{
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/ananthakumaran/toxiproxy-elixir"},
      maintainers: ["ananthakumaran@gmail.com"]
    }
  end

  defp docs do
    [
      source_url: "https://github.com/ananthakumaran/toxiproxy-elixir",
      source_ref: "v#{@version}",
      main: Toxiproxy,
      extras: ["README.md"]
    ]
  end
end
