defmodule GatewayService.PodcastByIdPlug do
  import Plug.Conn
  require Logger

  def get_podcast_by_id(conn) do
    params = conn.path_params
    request_url = "http://localhost:5000/podcast/" <> "#{params["id"]}"
    #    Logger.info("params: #{inspect(params["id"])}", ansi_color: :green)
    #    case HTTPoison.get(request_url, [], params: %{id: params["id"]}) do
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
