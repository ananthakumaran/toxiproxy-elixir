# Toxiproxy

[![Build Status](https://travis-ci.org/ananthakumaran/toxiproxy-elixir.svg?branch=master)](https://travis-ci.org/ananthakumaran/toxiproxy-elixir)

elixir client for [toxiproxy](https://github.com/Shopify/toxiproxy)

## Installation

Add `toxiproxy` to your list of dependencies in `mix.exs`:
```elixir
def deps do
  [{:toxiproxy, "~> 0.1.0"}]
end
```

Add the hostname and adapter in the config file.

```elixir
config :toxiproxy,
  host: "http://127.0.0.1:8474",
  adapter: Tesla.Adapter.Hackney
```

See [tesla](https://github.com/teamon/tesla#adapters-1) for the list
of supported adapters.


Ensure `toxiproxy` and the http library are started before your application:

```elixir
def application do
  [applications: [:hackney, :toxiproxy]]
end
```

