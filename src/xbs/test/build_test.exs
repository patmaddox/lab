defmodule XBS.BuildTest do
  use ExUnit.Case

  alias XBS.Build

  describe "calculate/2" do
    test "calculate using inputs" do
      b =
        Build.new(%{
          hello: %{calculate: fn store -> {:ok, "hello #{XBS.Store.get(store, :foo)}"} end}
        })

      assert Build.calculate(b, %{foo: "foo"}) == %{hello: "hello foo"}
    end

    test "no result on missing input" do
      b =
        Build.new(%{
          hello: %{calculate: fn store -> {:ok, "hello #{XBS.Store.get(store, :foo)}"} end}
        })

      assert Build.calculate(b, %{}) == %{}
    end
  end

  describe "current?/3" do
    test "true when matches given state" do
      b =
        Build.new(%{
          hello: %{calculate: fn store -> {:ok, "hello #{XBS.Store.get(store, :foo)}"} end}
        })

      assert Build.current?(b, %{foo: "foo"}, %{hello: "hello foo"})
    end

    test "false when different from given state" do
      b =
        Build.new(%{
          hello: %{calculate: fn store -> {:ok, "hello #{XBS.Store.get(store, :foo)}"} end}
        })

      refute Build.current?(b, %{foo: "foo"}, %{hello: "hello bar"})
    end

    test "false when calculated state is incomplete" do
      b =
        Build.new(%{
          hello: %{calculate: fn store -> {:ok, "hello #{XBS.Store.get(store, :foo)}"} end}
        })

      refute Build.current?(b, %{}, %{})
    end
  end
end
