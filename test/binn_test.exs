defmodule BinnTest do
  use ExUnit.Case
  doctest Binn

  test "greets the world" do
    assert Binn.hello() == :world
  end
end
