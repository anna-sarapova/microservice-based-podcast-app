defmodule AuthService3.StatusPlug do
  import Plug.Conn
  require Logger

  def status_endpoint(conn) do
    #    status = put_status(conn, :ok)
#    {:ok, timer_pid} = AuthService3.TaskTimeout.start_link(3000, conn)
    port = conn.port
    cursor = Mongo.find(:mongo, "Users", %{})
    #    Logger.info("users #{inspect(cursor)}", ansi_color: :yellow)
    #    Logger.info("users #{inspect(Enum.count(Map.get(cursor, :docs)))}", ansi_color: :cyan)
#    AuthService3.TaskTimeout.stop_timer(timer_pid)
    number_of_users = Enum.count(Map.get(cursor, :docs))
    response = %{status: "200", port: port, registered_users: number_of_users}
    encoded_response = Jason.encode!(response)
    send_resp(conn, 200, encoded_response)
  end

end
