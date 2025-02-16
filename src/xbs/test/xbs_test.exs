defmodule XBSTest.MakeFoo do
  def update(store) do
    outdir = XBS.Store.get(store, :outdir)

    outfile = "#{outdir}/foo"
    File.write!(outfile, "foo")
    outfile
  end
end

defmodule XBSTest.MakeBar do
  def update(store) do
    outdir = XBS.Store.get(store, :outdir)

    outfile = "#{outdir}/bar"
    File.write!(outfile, "bar")
    outfile
  end
end

defmodule XBSTest.MakeFooBar do
  def update(store) do
    outdir = XBS.Store.get(store, :outdir)
    foo = XBS.Store.get(store, :foo) |> File.read!()
    bar = XBS.Store.get(store, :bar) |> File.read!()

    outfile = "#{outdir}/foobar"
    File.write!(outfile, "this is #{foo}#{bar}")
    outfile
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
  end
end
