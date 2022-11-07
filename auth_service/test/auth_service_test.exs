defmodule AuthServiceTest.Router do
  use ExUnit.Case, async: true

  use Plug.Test

  @opts AuthService.Router.init([])
  @register_req_body %{
    name: "test",
    email: "test@email.com",
    password: "secret"
  }
  @login_req_body %{
    email: "test@email.com",
    password: "secret"
  }

  test "return ok" do
    # Build a connection which is GET request on / url
    conn = conn(:get, "/")
    # Then call Plug.call/2 with the connection and options
    conn = AuthService.Router.call(conn, @opts)
    # Finally we are using the assert/2 function to check for the
    # correctness of the response
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "OK"
  end

  test "register user" do
#    encoded_body = Jason.encode(@req_body)
    conn = conn(:post, "/register", @register_req_body)
    conn = AuthService.Router.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
  end

  test "login user" do
    #    encoded_body = Jason.encode(@req_body)
    conn = conn(:post, "/login", @login_req_body)
    conn = AuthService.Router.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Login Successful"
  end

  test "db healthcheck" do
    #    encoded_body = Jason.encode(@req_body)
    conn = conn(:get, "/healthcheck")
    conn = AuthService.Router.call(conn, @opts)
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "All good"
  end
end
