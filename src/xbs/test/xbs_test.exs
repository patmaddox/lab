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

  describe "get/2" do
    test "raise error on missing value" do
      store = XBS.new_store()

      assert_raise XBS.KeyNotFoundError, ~r/:foo/, fn ->
        XBS.get(store, :foo)
      end
    end
  end
end
