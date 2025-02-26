defmodule XBS.BuildTest do
  use ExUnit.Case

  alias XBS.Build

  describe "compute/2" do
    test "compute using inputs" do
      b =
        Build.new(%{
          hello: %{
            compute: fn -> {:ok, "hello #{XBS.Target.get!(:foo)}"} end,
            update: fn -> raise "never get here" end
          }
        })

      assert Build.compute(b, %{foo: "foo"}) == %{ok: [:hello], update: []}
    end

    test "no result on missing input" do
      b =
        Build.new(%{
          hello: %{
            compute: fn -> {:ok, "hello #{XBS.Target.get!(:foo)}"} end,
            update: fn -> raise "never get here" end
          }
        })

      assert Build.compute(b, %{}) == %{ok: [], update: [:hello]}
    end
  end
end
