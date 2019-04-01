defmodule Toxiproxy do
  def list() do
    Tesla.get(client(), "/proxies") |> extract
  end

  def populate(proxies) do
    Tesla.post(client(), "populate", proxies) |> extract
  end

  def create(proxy) do
    Tesla.post(client(), "/proxies", proxy) |> extract
  end

  def update(proxy) do
    Tesla.post(client(), "/proxies/" <> proxy.name, proxy) |> extract
  end

  def remove(proxy_name) do
    Tesla.delete(client(), "/proxies/" <> proxy_name) |> extract
  end

  def list_toxics(proxy_name) do
    Tesla.get(client(), "/proxies/#{proxy_name}/toxics") |> extract
  end

  def create_toxic(proxy_name, toxic) do
    Tesla.post(client(), "/proxies/#{proxy_name}/toxics", toxic) |> extract
  end

  def get_toxic(proxy_name, toxic_name) do
    Tesla.get(client(), "/proxies/#{proxy_name}/toxics/#{toxic_name}") |> extract
  end

  def update_toxic(proxy_name, toxic) do
    Tesla.post(client(), "/proxies/#{proxy_name}/toxics/#{toxic.name}", toxic) |> extract
  end

  def remove_toxic(proxy_name, toxic_name) do
    Tesla.delete(client(), "/proxies/#{proxy_name}/toxics/#{toxic_name}") |> extract
  end

  def reset() do
    Tesla.post(client(), "/reset", "") |> extract
  end

  def version() do
    Tesla.get(client(), "/version") |> extract
  end

  defp extract({:ok, %Tesla.Env{body: body, status: 200}}), do: {:ok, body}
  defp extract({:ok, %Tesla.Env{body: body, status: 201}}), do: {:ok, body}
  defp extract({:ok, %Tesla.Env{body: body, status: 204}}), do: {:ok, body}

  defp extract({:ok, %Tesla.Env{body: body, status: code}}) when code in [400, 409, 404],
    do: {:error, safe_decode(body)}

  defp extract({:error, result}), do: {:error, result}

  defp safe_decode(body) when is_binary(body) do
    case Poison.decode(body) do
      {:ok, result} -> result
      {:error, _} -> body
    end
  end

  defp safe_decode(body), do: body

  defp client do
    Tesla.client(
      [
        {Tesla.Middleware.BaseUrl,
         Application.get_env(:toxiproxy, :host, "http://127.0.0.1:8474")},
        {Tesla.Middleware.JSON, engine: Poison}
      ],
      Application.get_env(:toxiproxy, :adapter, Tesla.Adapter.Httpc)
    )
  end
end
