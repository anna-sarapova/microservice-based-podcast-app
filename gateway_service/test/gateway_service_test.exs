defmodule GatewayServiceTest do
  use ExUnit.Case
  doctest GatewayService

  test "greets the world" do
    assert GatewayService.hello() == :world
  end
end
