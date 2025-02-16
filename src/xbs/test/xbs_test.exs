defmodule XBSTest.MakeFoo do
  import XBS.Task

  def compute(store) do
    outdir = get(store, :outdir)
    outfile = "#{outdir}/foo"

    if File.exists?(outfile) do
      {:ok, outfile}
    else
      :update
    end
  end

  def update(store) do
    outdir = get(store, :outdir)

    outfile = "#{outdir}/foo"
    File.write!(outfile, "foo")
    {:ok, outfile}
  end
end

defmodule XBSTest.MakeBar do
  import XBS.Task

  def compute(_store), do: :update

  def update(store) do
    outdir = get(store, :outdir)

    outfile = "#{outdir}/bar"
    File.write!(outfile, "bar")
    {:ok, outfile}
  end
end

defmodule XBSTest.MakeFooBar do
  import XBS.Task

  def compute(_store), do: :update

  def update(store) do
    outdir = get(store, :outdir)
    foo = get(store, :foo) |> File.read!()
    bar = get(store, :bar) |> File.read!()

    outfile = "#{outdir}/foobar"
    File.write!(outfile, "this is #{foo}#{bar}")
    {:ok, outfile}
  end
end

defmodule XBSTest do
  use ExUnit.Case
  doctest XBS

  describe "compute/2" do
    test "return basic ok/update info" do
      build =
        XBS.new_build(%{
          foo: %{
            compute: fn _store -> {:ok, "some result"} end,
            update: fn _s -> raise "never get here" end
          },
          bar: %{compute: fn _store -> :update end, update: fn _s -> raise "never get here" end}
        })

      assert XBS.compute(build, %{}) == %{
               ok: [:foo],
               update: [:bar]
             }
    end

    test "targets need updating if their dependencies do" do
      build =
        XBS.new_build(%{
          foo: %{
            compute: fn _store -> :update end,
            update: fn _s -> raise "never get here" end
          },
          bar: %{
            compute: fn store -> {:ok, XBS.Store.get(store, :foo)} end,
            update: fn _s -> raise "never get here" end
          }
        })

      assert XBS.compute(build, %{}) == %{
               ok: [],
               update: [:bar, :foo]
             }
    end
  end

  describe "update/2" do
    test "success" do
      build =
        XBS.new_build(%{
          foo: XBSTest.MakeFoo,
          bar: XBSTest.MakeBar,
          foobar: XBSTest.MakeFooBar
        })

      Temp.track!()
      tmp_dir = Temp.mkdir!("xbs")

      assert :ok == XBS.update(build, %{outdir: tmp_dir})

      assert File.read!("#{tmp_dir}/foo") == "foo"
      assert File.read!("#{tmp_dir}/bar") == "bar"
      assert File.read!("#{tmp_dir}/foobar") == "this is foobar"
    end

    test "do not write a file if it exists" do
      build =
        XBS.new_build(%{
          foo: XBSTest.MakeFoo,
          bar: XBSTest.MakeBar,
          foobar: XBSTest.MakeFooBar
        })

      Temp.track!()
      tmp_dir = Temp.mkdir!("xbs")
      File.write!("#{tmp_dir}/foo", "oldfoo")

      assert :ok == XBS.update(build, %{outdir: tmp_dir})

      assert File.read!("#{tmp_dir}/foo") == "oldfoo"
      assert File.read!("#{tmp_dir}/bar") == "bar"
      assert File.read!("#{tmp_dir}/foobar") == "this is oldfoobar"
    end
  end
end
