defmodule AuthService.StatusPlug do
  import Plug.Conn
  require Logger

  def status_endpoint(conn) do
    #    status = put_status(conn, :ok)
    port = conn.port
    cursor = Mongo.find(:mongo, "Users", %{})
    #    Logger.info("users #{inspect(cursor)}", ansi_color: :yellow)
    #    Logger.info("users #{inspect(Enum.count(Map.get(cursor, :docs)))}", ansi_color: :cyan)
    number_of_users = Enum.count(Map.get(cursor, :docs))
    response = %{status: "200", port: port, registered_users: number_of_users}
    encoded_response = Jason.encode!(response)
    send_resp(conn, 200, encoded_response)
  end

end
