defmodule AuthService3.LoginPlug do
  import Plug.Conn
  require Logger

  def login_user(conn) do
#    {:ok, timer_pid} = AuthService3.TaskTimeout.start_link(3000, conn)
    Logger.info("received #{inspect(conn.body_params)}", ansi_color: :blue)
    case conn.body_params do
      %{"email" => email, "password" => password} ->
        found_user = Mongo.find_one(:mongo, "Users", %{email: email, password: password})
        if found_user do
#          AuthService3.TaskTimeout.stop_timer(timer_pid)
          Logger.info("found user #{inspect(found_user)}", ansi_color: :light_magenta)
          send_resp(conn, 200, "Login Successful")
        else
#          AuthService3.TaskTimeout.stop_timer(timer_pid)
          send_resp(conn, 404, "User not found")
        end
      _ ->
#        AuthService3.TaskTimeout.stop_timer(timer_pid)
        Logger.info("received #{inspect(conn.body_params)}", ansi_color: :yellow)
        send_resp(conn, 400, '')
    end
  end
end
