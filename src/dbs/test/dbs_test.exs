defmodule DBSTest do
  use ExUnit.Case
  doctest DBS

  test "calculate value from input values" do
    build = %{
      bar: fn store -> store[:foo] * 2 end,
      baz: fn _store -> "I am baz" end
    }

    assert DBS.get(build, %{}, %{foo: 1}) == %{bar: 2, baz: "I am baz"}
  end

  test "do not re-calculate values" do
    build = %{
      bar: fn store -> store[:foo] * 2 end,
      baz: fn _store -> "I am baz" end
    }

    assert DBS.get(build, %{bar: 123}, %{foo: 1}) == %{bar: 123, baz: "I am baz"}
  end
end
