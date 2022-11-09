defmodule AuthService3Test do
  use ExUnit.Case
  doctest AuthService3

  test "greets the world" do
    assert AuthService3.hello() == :world
  end
end
