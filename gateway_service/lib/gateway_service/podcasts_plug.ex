defmodule GatewayService.PodcastsPlug do
  import Plug.Conn
  require Logger

  def get_podcasts(conn) do
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
      {:error, reason} ->
        Logger.info("reason: #{inspect(reason)}", ansi_color: :magenta)
        send_resp(conn, 404, reason)
    end
  end

end
