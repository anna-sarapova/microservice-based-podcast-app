defmodule RegisteringService do
  use GenServer
  require Logger

  @service_discovery_address "http://service_discovery:8008/register_me"
  @request_body %{
    name: "auth_service",
    address: "http://auth_service3",
    port: 8082,
    status: "active"}

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def register_service() do
    {:ok, encoded_body} = Jason.encode(@request_body, [{:escape, :javascript_safe}])
    Logger.info(inspect(encoded_body), ansi_color: :blue)
    case HTTPoison.post(@service_discovery_address, encoded_body, [{"Accept", "application/json"}]) do
      {:ok, response} -> :ok
    end
  end

  def init(_opts) do
    register_service()
    {:ok, %{}}
  end

end