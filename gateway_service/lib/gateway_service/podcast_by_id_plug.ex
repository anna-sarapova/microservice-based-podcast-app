defmodule GatewayService.PodcastByIdPlug do
  import Plug.Conn
  require Logger

  @retry_errors [408, 500, 503]
  @retry_options %ExternalService.RetryOptions{
    #    Backoff strategy args: type_of_backoff(linear or exponential), delay, multiplication factor(only for linear)
    backoff: {:linear, 100, 1},
    #    Stop retrying after 5 seconds
    expiry: 5_000
  }
  @service_discovery_address "http://127.0.0.1:8008/service_registry"
  @service_name "content_retrieval"

  def get_podcast_by_id(conn) do
    ExternalService.call(:gateway_circuit_breaker, @retry_options, fn -> try_get_podcast(conn) end)
  end

  def try_get_podcast(conn) do
    case HTTPoison.get(@service_discovery_address) do
      {:ok, response} ->
        service_registry = Jason.decode!(response.body)
        #        Logger.info(inspect(service_registry), ansi_color: :yellow)]
        params = conn.path_params
        request_url = find_service(service_registry, params["id"])
        case HTTPoison.get(request_url) do
          {:ok, response} ->
            Logger.info("response: #{inspect(response)}", ansi_color: :green)
            #        encoded_response = Jason.encode!(response.body)
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, response.body)
          {:error, reason} ->
            #      {:error, reason, code} when code in @retry_errors ->
            Logger.info("reason: #{inspect(reason)}", ansi_color: :magenta)
            {:retry, reason}
          #        send_resp(conn, 503, reason)
          {:error, {:retries_exhausted, reason}} ->
            Logger.info("reason: #{inspect(reason)}", ansi_color: :magenta)
            send_resp(conn, 503, reason)
        end
    end
  end

  def find_service(service_registry, params) do
    service = Enum.find(service_registry, fn service -> service["name"] == @service_name end)
    request_url = "#{service["address"]}:#{service["port"]}/podcast/#{params}"
  end

end
