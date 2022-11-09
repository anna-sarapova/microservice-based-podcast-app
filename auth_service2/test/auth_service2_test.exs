defmodule AuthService2Test do
  use ExUnit.Case
  doctest AuthService2

  test "greets the world" do
    assert AuthService2.hello() == :world
  end
end
