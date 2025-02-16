defmodule XBS.TargetTest do
  use ExUnit.Case

  alias XBS.Target

  defmodule ExampleModule do
    def compute, do: {:ok, "example compute"}
    def update, do: {:ok, "example update"}
  end

  describe "compute/0" do
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
      {:ok, _} =
        Target.new(:foo, ExampleModule)

      assert Target.compute(:foo) == {:ok, "example compute"}
    end
  end

  describe("update/0") do
    test "returns the value" do
      {:ok, _} =
        Target.new(:foo, %{
          update: fn -> {:ok, "hello"} end
        })

      assert Target.update(:foo) == {:ok, "hello"}
    end

    test "caches the value (including compute/0)" do
      pid = self()

      {:ok, _} =
        Target.new(:foo, %{
          compute: fn ->
            send(pid, :computed)
            raise "never here"
          end,
          update: fn ->
            send(pid, :updated)
            {:ok, "hello"}
          end
        })

      assert Target.update(:foo) == {:ok, "hello"}
      assert_received :updated

      assert Target.update(:foo) == {:ok, "hello"}
      refute_received _

      assert Target.compute(:foo) == {:ok, "hello"}
      refute_received _
    end

    test "updates the value if it has previously been computed as needs updating" do
      {:ok, _} =
        Target.new(:foo, %{
          compute: fn -> :update end,
          update: fn -> {:ok, "hello"} end
        })

      assert Target.compute(:foo) == :update
      assert Target.update(:foo) == {:ok, "hello"}
    end

    test "can reference an input" do
      {:ok, _} =
        Target.new(:foo, %{
          update: fn -> {:ok, "foo"} end
        })

      {:ok, _} =
        Target.new(:foobar, %{
          update: fn -> {:ok, "#{Target.get!(:foo)}bar"} end
        })

      assert Target.update(:foobar) == {:ok, "foobar"}
    end

    test "errors if an input is missing" do
      {:ok, _} =
        Target.new(:foobar, %{
          update: fn -> {:ok, "#{Target.get!(:funky)}bar"} end
        })

      assert Target.update(:foobar) == {:error, {:key_not_found, :funky}}
    end

    test "updates inputs as needed" do
      {:ok, _} =
        Target.new(:foo, %{
          update: fn -> {:ok, "foo"} end
        })

      {:ok, _} =
        Target.new(:foobar, %{
          update: fn -> {:ok, "#{Target.get!(:foo)}bar"} end
        })

      assert Target.update(:foobar) == {:ok, "foobar"}
    end

    test "works with a module" do
      {:ok, _} =
        Target.new(:foo, ExampleModule)

      assert Target.update(:foo) == {:ok, "example update"}
    end
  end
end
