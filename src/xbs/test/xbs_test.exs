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

  describe "update" do
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
