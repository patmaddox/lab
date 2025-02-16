defmodule XBS.TargetTest do
  use ExUnit.Case

  alias XBS.Target

  describe "compute" do
    test "returns the value" do
      {:ok, _} =
        Target.new(:foo, %{
          compute: fn -> {:ok, "hello"} end
        })

      assert Target.compute(:foo) == {:ok, "hello"}
    end

    test "caches the value" do
      pid = self()

      {:ok, _} =
        Target.new(:foo, %{
          compute: fn ->
            send(pid, :computed)
            {:ok, "hello"}
          end
        })

      assert Target.compute(:foo) == {:ok, "hello"}
      assert_received :computed

      assert Target.compute(:foo) == {:ok, "hello"}
      refute_received _
    end

    test "can reference an input" do
      {:ok, _} =
        Target.new(:foo, %{
          compute: fn -> {:ok, "foo"} end
        })

      {:ok, _} =
        Target.new(:foobar, %{
          compute: fn -> {:ok, "#{Target.get!(:foo)}bar"} end
        })

      assert Target.compute(:foobar) == {:ok, "foobar"}
    end

    test "needs update if an input is missing" do
      {:ok, _} =
        Target.new(:foobar, %{
          compute: fn -> {:ok, "#{Target.get!(:foo)}bar"} end
        })

      assert Target.compute(:foobar) == :update
    end

    test "needs update if an input needs update" do
      {:ok, _} =
        Target.new(:foo, %{
          compute: fn -> :update end
        })

      {:ok, _} =
        Target.new(:foobar, %{
          compute: fn -> {:ok, "#{Target.get!(:foo)}bar"} end
        })

      assert Target.compute(:foobar) == :update
    end

    test "works with a module" do
      defmodule ExampleModule do
        def compute, do: {:ok, "example"}
      end

      {:ok, _} =
        Target.new(:foo, ExampleModule)

      assert Target.compute(:foo) == {:ok, "example"}
    end
  end
end
