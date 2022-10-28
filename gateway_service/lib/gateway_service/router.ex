defmodule GatewayService.Router do
  @moduledoc false
  require Logger

  # Bring Plug.Router module into scope
  use Plug.Router

  # Attach the Logger to log incoming requests
  plug(Plug.Logger)

  # Tell Plug to match the incoming request with the defined endpoints
  plug(:match)

  # Once there is a match, parse the response body if the content-type
  # is application/json. The order is important here, as we only want to
  # parse the body if there is a matching route.(Using the Jayson parser)
  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  # Dispatch the connection to the matched handler
  plug(:dispatch)

  # Handler for GET request with "/" path
  get "/" do
    send_resp(conn, 200, "OK")
  end

  post "/register" do
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

  post "/login" do
    request_url = "http://localhost:8080/login"
    request_body = conn.body_params
    Logger.info("req_body: #{inspect(request_body)}", ansi_color: :green)
    encoded_body = Jason.encode!(request_body)
#    Logger.info("encoded: #{inspect(request_body)}", ansi_color: :green)
    case HTTPoison.post(request_url, encoded_body, [{"Accept", "application/json"}]) do
      {:ok, response} ->
        Logger.info("response: #{inspect(response)}", ansi_color: :green)
        Logger.info("response: #{inspect(response.body)}", ansi_color: :green)
        encoded_response = Jason.encode!(response.body)
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, encoded_response)
      {:error, reason} ->
        Logger.info("reason: #{reason}", ansi_color: :magenta)
        send_resp(conn, 404, reason)
    end
  end

  get "/podcasts" do
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

  get "/podcast/:id" do
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

  # Fallback handler when there was no match
  match _ do
    send_resp(conn, 404, "Not Found")
  end
end
