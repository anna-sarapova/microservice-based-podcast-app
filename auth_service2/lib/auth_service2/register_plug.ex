defmodule AuthService2.RegisterPlug do
  import Plug.Conn
  require Logger

  def register_user(conn) do
    case conn.body_params do
      %{"name" => name, "email" => email, "password" => password} ->
        case Mongo.insert_one(:mongo, "Users", %{"name" => name, "email" => email, "password" => password}) do
          {:ok, user} ->
            Logger.info("received #{inspect(user)}", ansi_color: :light_magenta)
            document = Mongo.find_one(:mongo, "Users", %{_id: user.inserted_id})
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
end