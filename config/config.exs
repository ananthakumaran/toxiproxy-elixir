use Mix.Config

config :toxiproxy,
  host: "http://127.0.0.1:8474",
  adapter: Tesla.Adapter.Hackney
