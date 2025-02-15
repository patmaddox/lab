defmodule DBSTest do
  use ExUnit.Case
  doctest DBS

  test "greets the world" do
    assert DBS.hello() == :world
  end
end
