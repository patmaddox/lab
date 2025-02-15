defmodule XBSTest do
  use ExUnit.Case
  doctest XBS

  describe "compute/3" do
    test "with no inputs" do
      store = XBS.new_store()

      build =
        XBS.new_build(%{
          foo: %{inputs: [], compute: fn _store -> "I am foo" end}
        })

      assert XBS.compute(build, store, %{}) == %{foo: "I am foo"}
    end

    test "when input is satisfied" do
      store = XBS.new_store()

      build =
        XBS.new_build(%{
          foo: %{
            compute: fn store -> "I am foo, you are #{XBS.get(store, :bar)}" end
          }
        })

      assert XBS.compute(build, store, %{bar: "bar"}) == %{foo: "I am foo, you are bar"}
    end

    test "when input comes from store" do
      store = XBS.new_store(%{bar: "bar"})

      build =
        XBS.new_build(%{
          foo: %{
            compute: fn store -> "I am foo, you are #{XBS.get(store, :bar)}" end
          }
        })

      assert XBS.compute(build, store, %{}) == %{foo: "I am foo, you are bar"}
    end

    test "skip when input is not satisfied" do
      store = XBS.new_store()

      build =
        XBS.new_build(%{
          foo: %{
            compute: fn store -> "I am foo, you are #{XBS.get(store, :bar)}" end
          }
        })

      assert XBS.compute(build, store, %{}) == %{}
    end
  end

  describe "update/3" do
    test "calculate value from input values" do
      store = XBS.new_store()

      build =
        XBS.new_build(%{
          bar: fn store -> XBS.get(store, :foo) * 2 end,
          baz: fn _store -> "I am baz" end
        })

      assert XBS.update(build, store, %{foo: 1}) == %{bar: 2, baz: "I am baz"}
    end

    test "do not re-calculate values" do
      store = XBS.new_store(%{bar: 123})

      build =
        XBS.new_build(%{
          bar: fn store -> XBS.get(store, :foo) * 2 end,
          baz: fn _store -> "I am baz" end
        })

      assert XBS.update(build, store, %{foo: 1}) == %{bar: 123, baz: "I am baz"}
    end
  end

  describe "get/2" do
    test "raise error on missing value" do
      store = XBS.new_store()

      assert_raise XBS.KeyNotFoundError, ~r/:foo/, fn ->
        XBS.get(store, :foo)
      end
    end
  end
end
