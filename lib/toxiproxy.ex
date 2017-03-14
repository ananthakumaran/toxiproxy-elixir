defmodule Toxiproxy do
  defmodule API do
    @moduledoc false

    use Tesla, only: [:get, :post, :delete]

    plug Tesla.Middleware.BaseUrl, Application.get_env(:toxiproxy, :host, "http://127.0.0.1:8474")
    plug Tesla.Middleware.JSON

    adapter Application.get_env(:toxiproxy, :adapter, Tesla.Adapter.Httpc)
  end

  def list() do
    API.get("/proxies") |> extract
  end

  def populate(proxies) do
    API.post("populate", proxies) |> extract
  end

  def create(proxy) do
    API.post("/proxies", proxy) |> extract
  end

  def update(proxy) do
    API.post("/proxies/" <> proxy.name, proxy) |> extract
  end

  def remove(proxy_name) do
    API.delete("/proxies/" <> proxy_name) |> extract
  end

  def list_toxics(proxy_name) do
    API.get("/proxies/#{proxy_name}/toxics") |> extract
  end

  def create_toxic(proxy_name, toxic) do
    API.post("/proxies/#{proxy_name}/toxics", toxic) |> extract
  end

  def get_toxic(proxy_name, toxic_name) do
    API.get("/proxies/#{proxy_name}/toxics/#{toxic_name}") |> extract
  end

  def update_toxic(proxy_name, toxic) do
    API.post("/proxies/#{proxy_name}/toxics/#{toxic.name}", toxic) |> extract
  end

  def remove_toxic(proxy_name, toxic_name) do
    API.delete("/proxies/#{proxy_name}/toxics/#{toxic_name}") |> extract
  end

  def reset() do
    API.post("/reset", "") |> extract
  end

  def version() do
    API.get("/version") |> extract
  end

  defp extract(%Tesla.Env{body: body, status: 200}), do: {:ok, body}
  defp extract(%Tesla.Env{body: body, status: 201}), do: {:ok, body}
  defp extract(%Tesla.Env{body: body, status: 204}), do: {:ok, body}
  defp extract(%Tesla.Env{body: body, status: code}) when code in [400, 409, 404], do: {:error, safe_decode(body)}
  defp extract(result), do: {:error, result}

  defp safe_decode(body) when is_binary(body) do
    case Poison.decode(body) do
      {:ok, result} -> result
      {:error, _} -> body
    end
  end
  defp safe_decode(body), do: body
end
