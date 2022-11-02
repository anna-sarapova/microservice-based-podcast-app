defmodule GatewayService.RegisterPlug do
  import Plug.Conn
  require Logger

  def register_user(conn) do
    request_url = "http://localhost:8080/register"
    request_body = conn.body_params
    case HTTPoison.post(request_url, request_body, [{"Accept", "application/json"}]) do
      {:ok, response} ->
        encoded_response = Jason.encode!(response)
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, encoded_response)
      {:error, reason} ->
        Logger.info("reason: #{reason}", ansi_color: :magenta)
        send_resp(conn, 500, reason)
    end
  end

end
