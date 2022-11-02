defmodule AuthService.LoginPlug do
  import Plug.Conn
  require Logger

  def login_user(conn) do
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
        Logger.info("received #{inspect(conn.body_params)}", ansi_color: :yellow)
        send_resp(conn, 400, '')
    end
  end
end
