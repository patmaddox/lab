defmodule XBS.StoreTest do
  use ExUnit.Case

  alias XBS.Store

  describe "get" do
    test "raises an error when there is no task" do
      store = Store.new()

      assert_raise XBS.KeyNotFoundError, ~r/:foo/, fn ->
        Store.get(store, :foo)
      end
    end

    test "calculates the value when there is a task" do
      store = Store.new()
      Store.add_task(store, :foo, fn _store -> "hello" end)
      assert Store.get(store, :foo) == "hello"
    end

    test "calculate the value with a dependency" do
      store = Store.new()
      Store.add_task(store, :foo, fn _store -> "foo" end)
      Store.add_task(store, :foobar, fn s -> "hello #{Store.get(s, :foo)}" end)
      assert Store.get(store, :foobar) == "hello foo"
    end

    test "calculate the value from initial state" do
      store = Store.new(%{foo: "foo"})
      Store.add_task(store, :foobar, fn s -> "hello #{Store.get(s, :foo)}" end)
      assert Store.get(store, :foobar) == "hello foo"
    end

    test "caches a calculated value" do
      pid = self()

      store = Store.new()

      Store.add_task(store, :foo, fn _store ->
        send(pid, :calculated)
        "hello"
      end)

      assert Store.get(store, :foo) == "hello"
      assert_received :calculated

      assert Store.get(store, :foo) == "hello"
      refute_received _
    end

    test "calls module.update(store) if task is a module" do
      defmodule JustReturn do
        def update(_store) do
          "just return something"
        end
      end

      store = Store.new(%{})
      Store.add_task(store, :foo, JustReturn)
      assert Store.get(store, :foo) == "just return something"
    end
  end
end
