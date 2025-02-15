defmodule XBSTest do
  use ExUnit.Case
  doctest XBS

  describe "compute/3" do
    test "with no inputs" do
      tasks = %{foo: %{inputs: [], compute: fn _store -> "I am foo" end}}
      assert XBS.compute(tasks, %{}, %{}) == %{foo: "I am foo"}
    end

    test "when input is satisfied" do
      tasks = %{foo: %{compute: fn store -> "I am foo, you are #{XBS.get(store, :bar)}" end}}
      assert XBS.compute(tasks, %{}, %{bar: "bar"}) == %{foo: "I am foo, you are bar"}
    end

    test "when input comes from store" do
      tasks = %{foo: %{compute: fn store -> "I am foo, you are #{XBS.get(store, :bar)}" end}}
      assert XBS.compute(tasks, %{bar: "bar"}, %{}) == %{foo: "I am foo, you are bar"}
    end

    test "skip when input is not satisfied" do
      tasks = %{foo: %{compute: fn store -> "I am foo, you are #{XBS.get(store, :bar)}" end}}
      assert XBS.compute(tasks, %{}, %{}) == %{}
    end
  end

  describe "get/2" do
    test "raise error on missing value" do
      assert_raise XBS.KeyNotFoundError, ~r/:foo/, fn ->
        XBS.get(%{}, :foo)
      end
    end
  end
end
