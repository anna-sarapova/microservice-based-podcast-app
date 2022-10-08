defmodule AuthServiceTest.Router do
  use ExUnit.Case, async: true

  use Plug.Test

  @opts AuthService.Router.init([])

  test "return ok" do
    # Build a connection which is GET request on / url
    conn = conn(:get, "/")
    # Then call Plug.call/2 with the connection and options
    conn = AuthService.Router.call(conn, @opts)
    # Finally we are using the assert/2 function to check for the
    # correctness of the response
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"  end
end
