defmodule AuthService.RegisterPlug do
  import Plug.Conn
  require Logger

  def register_user(conn) do
#    {:ok, timer_pid} = AuthService.TaskTimeout.start_link(3000, conn)
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
#            AuthService.TaskTimeout.stop_timer(timer_pid)
            conn
            # Sets the value of the "content-type" response header
            |> put_resp_content_type("application/json")
            |> send_resp(200, response)
          {:error, _} ->
#            AuthService.TaskTimeout.stop_timer(timer_pid)
            send_resp(conn, 500, "Something went wrong")
        end
      _ ->
#        AuthService.TaskTimeout.stop_timer(timer_pid)
        send_resp(conn, 400, '')
    end
  end
end