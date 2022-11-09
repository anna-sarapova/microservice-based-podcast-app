defmodule AuthService2.Router do
  require Logger
#  alias AuthService.JSONUtils, as: JSON

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

  get "/healthcheck" do
    case Mongo.command(:mongo, ping: 1) do
      {:ok, _res} -> send_resp(conn, 200, "All good")
      {:error, _err} -> send_resp(conn, 500, "Something went wrong")
    end
  end

  post "/register" do
    AuthService2.RegisterPlug.register_user(conn)
  end

  post "/login" do
    AuthService2.LoginPlug.login_user(conn)
  end

  get "/status" do
    AuthService2.StatusPlug.status_endpoint(conn)
  end

  # Fallback handler when there was no match
  match _ do
    send_resp(conn, 404, "Not Found")
  end

end
