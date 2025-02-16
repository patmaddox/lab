defmodule XBS.StoreTest do
  use ExUnit.Case

  alias XBS.Store

  describe "get" do
    test "raises an error when there is no target" do
      store = Store.new()

      assert_raise XBS.KeyNotFoundError, ~r/:foo/, fn ->
        Store.get(store, :foo)
      end
    end

    test "compute the value when there is a target" do
      store = Store.new()

      Store.add_target(store, :foo, %{
        compute: fn _store -> {:ok, "hello"} end,
        update: fn _s -> raise "never get here" end
      })

      assert Store.get(store, :foo) == "hello"
    end

    test "compute the value with a dependency" do
      store = Store.new()

      Store.add_target(store, :foo, %{
        compute: fn _store -> {:ok, "foo"} end,
        update: fn _s -> raise "never get here" end
      })

      Store.add_target(store, :foobar, %{
        compute: fn s -> {:ok, "hello #{Store.get(s, :foo)}"} end,
        update: fn _s -> raise "never get here" end
      })

      assert Store.get(store, :foobar) == "hello foo"
    end

    test "compute the value from initial state" do
      store = Store.new(%{foo: "foo"})

      Store.add_target(store, :foobar, %{
        compute: fn s -> {:ok, "hello #{Store.get(s, :foo)}"} end,
        update: fn _s -> raise "never get here" end
      })

      assert Store.get(store, :foobar) == "hello foo"
    end

    test "caches a computed value" do
      pid = self()

      store = Store.new()

      Store.add_target(store, :foo, %{
        compute: fn _store ->
          send(pid, :computed)
          {:ok, "hello"}
        end,
        update: fn _s -> raise "never get here" end
      })

      assert Store.get(store, :foo) == "hello"
      assert_received :computed

      assert Store.get(store, :foo) == "hello"
      refute_received _
    end
  end

  describe "get (compute mode)" do
    test "raises an error if an update is needed" do
      store = Store.new(%{})

      Store.add_target(store, :foo, %{
        compute: fn _store -> :update end,
        update: fn _store -> {:ok, "got an update"} end
      })

      assert_raise XBS.NeedsUpdateError, ~r/:foo/, fn ->
        Store.get(store, :foo)
      end
    end
  end

  describe "get (update mode)" do
    test "calls function-style update(store) if target needs an update" do
      store = Store.new(%{}, :update)

      Store.add_target(store, :foo, %{
        compute: fn _store -> :update end,
        update: fn _store -> {:ok, "got an update"} end
      })

      assert Store.get(store, :foo) == "got an update"
    end

    test "returns computed value if no update needed" do
      store = Store.new(%{}, :update)

      Store.add_target(store, :foo, %{
        compute: fn _store -> {:ok, "no update needed"} end,
        update: fn _s -> raise "never get here" end
      })

      assert Store.get(store, :foo) == "no update needed"
    end

    test "calls module.update(store) if target needs an update" do
      defmodule JustReturn do
        def compute(_store) do
          :update
        end

        def update(_store) do
          {:ok, "just return something"}
        end
      end

      store = Store.new(%{}, :update)
      Store.add_target(store, :foo, JustReturn)
      assert Store.get(store, :foo) == "just return something"
    end

    test "does not call module.update if target does not need an update" do
      defmodule NoUpdateNeeded do
        def compute(_store) do
          {:ok, "no update needed"}
        end

        def update(_store) do
          raise "should never get here"
        end
      end

      store = Store.new(%{}, :update)
      Store.add_target(store, :foo, NoUpdateNeeded)
      assert Store.get(store, :foo) == "no update needed"
    end
  end
end
