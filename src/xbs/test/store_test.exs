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

    test "compute the value when there is a task" do
      store = Store.new()
      Store.add_task(store, :foo, fn _store -> {:ok, "hello"} end)
      assert Store.get(store, :foo) == "hello"
    end

    test "compute the value with a dependency" do
      store = Store.new()
      Store.add_task(store, :foo, fn _store -> {:ok, "foo"} end)
      Store.add_task(store, :foobar, fn s -> {:ok, "hello #{Store.get(s, :foo)}"} end)
      assert Store.get(store, :foobar) == "hello foo"
    end

    test "compute the value from initial state" do
      store = Store.new(%{foo: "foo"})
      Store.add_task(store, :foobar, fn s -> {:ok, "hello #{Store.get(s, :foo)}"} end)
      assert Store.get(store, :foobar) == "hello foo"
    end

    test "caches a computed value" do
      pid = self()

      store = Store.new()

      Store.add_task(store, :foo, fn _store ->
        send(pid, :computed)
        {:ok, "hello"}
      end)

      assert Store.get(store, :foo) == "hello"
      assert_received :computed

      assert Store.get(store, :foo) == "hello"
      refute_received _
    end

    test "calls module.update(store) if task needs an update" do
      defmodule JustReturn do
        def compute(_store) do
          :update
        end

        def update(_store) do
          {:ok, "just return something"}
        end
      end

      store = Store.new(%{})
      Store.add_task(store, :foo, JustReturn)
      assert Store.get(store, :foo) == "just return something"
    end

    test "does not call module.update if task does not need an update" do
      defmodule NoUpdateNeeded do
        def compute(_store) do
          {:ok, "no update needed"}
        end

        def update(_store) do
          raise "should never get here"
        end
      end

      store = Store.new(%{})
      Store.add_task(store, :foo, NoUpdateNeeded)
      assert Store.get(store, :foo) == "no update needed"
    end
  end
end
