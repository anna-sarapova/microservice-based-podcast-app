defmodule GatewayService.RegisterPlug do
  import Plug.Conn
  require Logger

  @retry_errors [408, 500, 503]
  @retry_options %ExternalService.RetryOptions{
#    Backoff strategy args: type_of_backoff(linear or exponential), delay, multiplication factor(only for linear)
    backoff: {:linear, 100, 1},
#    Stop retrying after 5 seconds
    expiry: 5_000
  }

  def register_user(conn) do
    ExternalService.call(:gateway_circuit_breaker, @retry_options, fn -> try_register(conn) end)
  end

  def try_register(conn) do
    request_url = "http://localhost:8080/register"
    request_body = conn.body_params
    case HTTPoison.post(request_url, request_body, [{"Accept", "application/json"}]) do
      {:ok, response} ->
        encoded_response = Jason.encode!(response)
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, encoded_response)
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
