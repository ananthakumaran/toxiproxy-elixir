defmodule ToxiproxyTest do
  use ExUnit.Case, async: false
  import Toxiproxy

  setup do
    {:ok, proxies} = list()

    for {proxy, _} <- proxies do
      {:ok, _} = remove(proxy)
    end

    :ok
  end

  test "list" do
    assert {:ok, %{}} == list()
    assert {:ok, _} = create(%{name: "mysql", upstream: "localhost:3535"})

    assert {:ok,
            %{
              "mysql" => %{
                "enabled" => true,
                "listen" => _,
                "name" => "mysql",
                "toxics" => [],
                "upstream" => "localhost:3535"
              }
            }} = list()
  end

  test "create" do
    assert {:error, _} = create(%{name: "mysql"})

    assert {:ok,
            %{
              "enabled" => true,
              "listen" => _,
              "name" => "mysql",
              "toxics" => [],
              "upstream" => "localhost:3535"
            }} = create(%{name: "mysql", upstream: "localhost:3535"})

    assert {:error, %{"error" => "proxy already exists", "status" => 409}} ==
             create(%{name: "mysql", upstream: "localhost:3535"})
  end

  test "update" do
    assert {:error, %{"error" => "proxy not found", "status" => 404}} =
             update(%{name: "mysql", enabled: false})

    assert {:ok, _} = create(%{name: "mysql", upstream: "localhost:3535"})

    assert {:ok,
            %{
              "enabled" => false,
              "listen" => _,
              "name" => "mysql",
              "toxics" => [],
              "upstream" => "localhost:3535"
            }} = update(%{name: "mysql", enabled: false})

    assert {:ok,
            %{
              "enabled" => true,
              "listen" => _,
              "name" => "mysql",
              "toxics" => [],
              "upstream" => "localhost:4545"
            }} = update(%{name: "mysql", upstream: "localhost:4545", enabled: true})
  end

  test "populate" do
    assert {:ok, _} = populate([])

    assert {:ok, %{"proxies" => [%{"enabled" => true, "name" => "mysql"}]}} =
             populate([%{name: "mysql", upstream: "localhost:4545", enabled: true}])
  end

  test "remove" do
    assert {:error, %{"error" => "proxy not found", "status" => 404}} == remove("mysql")
    assert {:ok, _} = create(%{name: "mysql", upstream: "localhost:3535"})
    assert {:ok, _} = remove("mysql")
  end

  test "list_toxics" do
    assert {:error, _} = list_toxics("mysql")
    assert {:ok, _} = create(%{name: "mysql", upstream: "localhost:3535"})
    assert {:ok, []} = list_toxics("mysql")

    assert {:ok, %{"attributes" => %{"jitter" => 1000}, "type" => "latency"}} =
             create_toxic("mysql", %{type: "latency", attributes: %{jitter: 1000}})

    assert {:ok, [%{"attributes" => %{"jitter" => 1000}, "type" => "latency"}]} =
             list_toxics("mysql")
  end

  test "create_toxic" do
    assert {:error, %{"error" => "proxy not found", "status" => 404}} =
             create_toxic("mysql", %{type: "latency", attributes: %{jitter: 1000}})

    assert {:ok, _} = create(%{name: "mysql", upstream: "localhost:3535"})

    assert {:ok, %{"attributes" => %{"jitter" => 1000}, "type" => "latency"}} =
             create_toxic("mysql", %{type: "latency", attributes: %{jitter: 1000}})
  end

  test "get_toxic" do
    assert {:error, %{"error" => "proxy not found", "status" => 404}} =
             get_toxic("mysql", "mysql_timeout")

    assert {:ok, _} = create(%{name: "mysql", upstream: "localhost:3535"})

    assert {:error, %{"error" => "toxic not found", "status" => 404}} =
             get_toxic("mysql", "mysql_timeout")

    assert {:ok, _} = create_toxic("mysql", %{type: "latency", attributes: %{jitter: 1000}})

    assert {:ok,
            %{
              "attributes" => %{"jitter" => 1000, "latency" => 0},
              "name" => "latency_downstream",
              "stream" => "downstream",
              "toxicity" => 1,
              "type" => "latency"
            }} = get_toxic("mysql", "latency_downstream")
  end

  test "update_toxic" do
    assert {:ok, _} = create(%{name: "mysql", upstream: "localhost:3535"})

    assert {:error, %{"error" => "toxic not found", "status" => 404}} =
             update_toxic("mysql", %{name: "latency_downstream", toxicity: 0.5})

    assert {:ok, _} = create_toxic("mysql", %{type: "latency", attributes: %{jitter: 1000}})

    assert {:ok, %{"toxicity" => 0.5}} =
             update_toxic("mysql", %{name: "latency_downstream", toxicity: 0.5})
  end

  test "remove_toxic" do
    assert {:ok, _} = create(%{name: "mysql", upstream: "localhost:3535"})

    assert {:error, %{"error" => "toxic not found", "status" => 404}} =
             remove_toxic("mysql", "latency_downstream")

    assert {:ok, _} = create_toxic("mysql", %{type: "latency", attributes: %{jitter: 1000}})
    assert {:ok, _} = remove_toxic("mysql", "latency_downstream")
    assert {:ok, []} = list_toxics("mysql")
  end

  test "reset" do
    assert {:ok, ""} = reset()
    assert {:ok, _} = create(%{name: "mysql", upstream: "localhost:3535"})
    assert {:ok, _} = create_toxic("mysql", %{type: "latency", attributes: %{jitter: 1000}})
    assert {:ok, [%{"name" => "latency_downstream"}]} = list_toxics("mysql")
    assert {:ok, ""} = reset()
    assert {:ok, []} = list_toxics("mysql")
  end

  test "version" do
    assert {:ok, _} = version()
  end
end
