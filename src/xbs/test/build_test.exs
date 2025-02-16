defmodule XBS.BuildTest do
  use ExUnit.Case

  alias XBS.Build

  describe "compute/2" do
    test "compute using inputs" do
      b =
        Build.new(%{
          hello: %{compute: fn store -> {:ok, "hello #{XBS.Store.get(store, :foo)}"} end}
        })

      assert Build.compute(b, %{foo: "foo"}) == %{hello: "hello foo"}
    end

    test "no result on missing input" do
      b =
        Build.new(%{
          hello: %{compute: fn store -> {:ok, "hello #{XBS.Store.get(store, :foo)}"} end}
        })

      assert Build.compute(b, %{}) == %{}
    end
  end

  describe "current?/3" do
    test "true when matches given state" do
      b =
        Build.new(%{
          hello: %{compute: fn store -> {:ok, "hello #{XBS.Store.get(store, :foo)}"} end}
        })

      assert Build.current?(b, %{foo: "foo"}, %{hello: "hello foo"})
    end

    test "false when different from given state" do
      b =
        Build.new(%{
          hello: %{compute: fn store -> {:ok, "hello #{XBS.Store.get(store, :foo)}"} end}
        })

      refute Build.current?(b, %{foo: "foo"}, %{hello: "hello bar"})
    end

    test "false when computed state is incomplete" do
      b =
        Build.new(%{
          hello: %{compute: fn store -> {:ok, "hello #{XBS.Store.get(store, :foo)}"} end}
        })

      refute Build.current?(b, %{}, %{})
    end
  end
end
