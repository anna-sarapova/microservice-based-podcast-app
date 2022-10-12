defmodule AuthService.Router do
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
    case conn.body_params do
      %{"name" => name, "email" => email, "password" => password} ->
        case Mongo.insert_one(:mongo, "Users", %{"name" => name, "email" => email, "password" => password}) do
          {:ok, user} ->
            Logger.info("received #{inspect(user)}", ansi_color: :light_magenta)
            document = Mongo.find_one(:mongo, "Users", %{_id: user.inserted_id})
#            response =
#              JSON.normaliseMongoId(document)
#              |> Jason.encode!()
            response = Jason.encode!(document)
            conn
            # Sets the value of the "content-type" response header
            |> put_resp_content_type("application/json")
            |> send_resp(200, response)
          {:error, _} ->
            send_resp(conn, 500, "Something went wrong")
        end
      _ ->
        send_resp(conn, 400, '')
    end
  end

  post "/login" do
    Logger.info("received #{inspect(conn.body_params)}", ansi_color: :blue)
    case conn.body_params do
      %{"email" => email, "password" => password} ->
        found_user = Mongo.find_one(:mongo, "Users", %{email: email, password: password})
        if found_user do
          Logger.info("found user #{inspect(found_user)}", ansi_color: :light_magenta)
          send_resp(conn, 200, "Login Successful")
        else
          send_resp(conn, 404, "User not found")
        end
      _ ->
        Logger.info("received #{inspect(conn.body_params)}", ansi_color: :blue)
        send_resp(conn, 400, '')
    end
  end

#  get "/status" do
##    status = put_status(conn, :ok)
#    port = conn.port
#    a = Mongo.find(:mongo, "Users", %{})
#    Logger.info("users #{inspect(a)}")
#    registered_users = Map.keys(Mongo.find(:mongo, "Users", %{}))
#    Logger.info("#{inspect(registered_users)}")
#    Logger.info("#{inspect(registered_users.docs)}")
#    number_of_users = Enum.count(registered_users.docs)
#    response = %{status: "200", port: port, registered_users: number_of_users}
#    encoded_response = Jason.encode!(response)
#    send_resp(conn, 200, encoded_response)
#  end

  # Fallback handler when there was no match
  match _ do
    send_resp(conn, 404, "Not Found")
  end

end
