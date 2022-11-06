defmodule GatewayService.PodcastsPlug do
  import Plug.Conn
  require Logger

  @retry_errors [408, 500, 503]
  @retry_options %ExternalService.RetryOptions{
    #    Backoff strategy args: type_of_backoff(linear or exponential), delay, multiplication factor(only for linear)
    backoff: {:linear, 100, 1},
    #    Stop retrying after 5 seconds
    expiry: 5_000
  }

  def get_podcasts(conn) do
    ExternalService.call(:gateway_circuit_breaker, @retry_options, fn -> try_get_podcasts(conn) end)
  end

  def try_get_podcasts(conn) do
    request_url = "http://localhost:5000/podcasts"
    #    params = conn.path_params
    #    Logger.info("params: #{inspect(params)}", ansi_color: :green)
    case HTTPoison.get(request_url) do
      {:ok, response} ->
        Logger.info("response: #{inspect(response)}", ansi_color: :green)
        #        encoded_response = Jason.encode!(response.body)
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, response.body)
#      {:error, reason} ->
      {:error, reason, code} when code in @retry_errors ->
        Logger.info("reason: #{inspect(reason)}", ansi_color: :magenta)
        {:retry, reason}
#        send_resp(conn, 404, reason)
    end
  end

end
