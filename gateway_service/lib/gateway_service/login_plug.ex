defmodule GatewayService.LoginPlug do
  import Plug.Conn
  require Logger

  @retry_errors [408, 500, 503]
  @retry_options %ExternalService.RetryOptions{
    #    Backoff strategy args: type_of_backoff(linear or exponential), delay, multiplication factor(only for linear)
    backoff: {:linear, 100, 1},
    #    Stop retrying after 5 seconds
    expiry: 5_000
  }

  def login_user(conn) do
    ExternalService.call(:gateway_circuit_breaker, @retry_options, fn -> try_login(conn) end)
  end

  def try_login(conn) do
    request_url = "http://localhost:8080/login"
    request_body = conn.body_params
    #    request_body = %{"email" => "tammy@mail.com", "password" => "secret"}
    Logger.info("req_body: #{inspect(request_body)}", ansi_color: :green)
    encoded_body = Jason.encode!(request_body)
    #    Logger.info("encoded: #{inspect(request_body)}", ansi_color: :green)
    headers = [{"Content-type", "application/json"}]
    case HTTPoison.post(request_url, encoded_body, headers, []) do
      #    case HTTPoison.request(:post, request_url, request_body, headers, []) do
      {:ok, response} ->
        Logger.info("response: #{inspect(response)}", ansi_color: :green)
        Logger.info("response: #{inspect(response.body)}", ansi_color: :green)
        encoded_response = Jason.encode!(response.body)
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
