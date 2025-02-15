defmodule DBSTest do
  use ExUnit.Case
  doctest DBS

  describe "compute/3" do
    test "with no inputs" do
      store = DBS.new_store()

      build =
        DBS.new_build(%{
          foo: %{inputs: [], compute: fn _store -> "I am foo" end}
        })

      assert DBS.compute(build, store, %{}) == %{foo: "I am foo"}
    end

    test "when input is satisfied" do
      store = DBS.new_store()

      build =
        DBS.new_build(%{
          foo: %{
            inputs: [:bar],
            compute: fn store -> "I am foo, you are #{store.bar}" end
          }
        })

      assert DBS.compute(build, store, %{bar: "bar"}) == %{foo: "I am foo, you are bar"}
    end

    test "when input comes from store" do
      store = DBS.new_store(%{bar: "bar"})

      build =
        DBS.new_build(%{
          foo: %{
            inputs: [:bar],
            compute: fn store -> "I am foo, you are #{store.bar}" end
          }
        })

      assert DBS.compute(build, store, %{}) == %{foo: "I am foo, you are bar"}
    end

    test "skip when input is not satisfied" do
      store = DBS.new_store()

      build =
        DBS.new_build(%{
          foo: %{
            inputs: [:bar],
            compute: fn store -> "I am foo, you are #{store.bar}" end
          }
        })

      assert DBS.compute(build, store, %{}) == %{}
    end
  end

  test "calculate value from input values" do
    store = DBS.new_store()

    build =
      DBS.new_build(%{
        bar: fn store -> DBS.get(store, :foo) * 2 end,
        baz: fn _store -> "I am baz" end
      })

    assert DBS.build(build, store, %{foo: 1}) == %{bar: 2, baz: "I am baz"}
  end

  test "do not re-calculate values" do
    store = DBS.new_store(%{bar: 123})

    build =
      DBS.new_build(%{
        bar: fn store -> DBS.get(store, :foo) * 2 end,
        baz: fn _store -> "I am baz" end
      })

    assert DBS.build(build, store, %{foo: 1}) == %{bar: 123, baz: "I am baz"}
  end

  test "raise error on missing value" do
    store = DBS.new_store()

    assert_raise RuntimeError, ~r/unable to resolve :foo/, fn ->
      DBS.get(store, :foo)
    end
  end
end
