defmodule DBSTest do
  use ExUnit.Case
  doctest DBS

  test "calculate value from input values" do
    store = DBS.new_store()

    build = %{
      bar: fn store -> DBS.get(store, :foo) * 2 end,
      baz: fn _store -> "I am baz" end
    }

    assert DBS.build(build, store, %{foo: 1}) == %{bar: 2, baz: "I am baz"}
  end

  test "do not re-calculate values" do
    store = DBS.new_store(%{bar: 123})

    build = %{
      bar: fn store -> DBS.get(store, :foo) * 2 end,
      baz: fn _store -> "I am baz" end
    }

    assert DBS.build(build, store, %{foo: 1}) == %{bar: 123, baz: "I am baz"}
  end
end
