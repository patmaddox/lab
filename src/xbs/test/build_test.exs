defmodule XBS.BuildTest do
  use ExUnit.Case

  alias XBS.Build

  describe "calculate/2" do
    test "calculate using inputs" do
      b =
        Build.new(%{
          hello: %{calculate: fn store -> "hello #{XBS.Store.get(store, :foo)}" end}
        })

      assert Build.calculate(b, %{foo: "foo"}) == %{hello: "hello foo"}
    end

    test "no result on missing input" do
      b =
        Build.new(%{
          hello: %{calculate: fn store -> "hello #{XBS.Store.get(store, :foo)}" end}
        })

      assert Build.calculate(b, %{}) == %{}
    end
  end
end

