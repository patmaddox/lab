defmodule XBSTest.MakeFoo do
  import XBS.Target

  def compute do
    outdir = get!(:outdir)
    outfile = "#{outdir}/foo"

    if File.exists?(outfile) do
      {:ok, outfile}
    else
      :update
    end
  end

  def update do
    outdir = get!(:outdir)

    outfile = "#{outdir}/foo"
    File.write!(outfile, "foo")
    {:ok, outfile}
  end
end

defmodule XBSTest.MakeBar do
  import XBS.Target

  def compute, do: :update

  def update do
    outdir = get!(:outdir)

    outfile = "#{outdir}/bar"
    File.write!(outfile, "bar")
    {:ok, outfile}
  end
end

defmodule XBSTest.MakeFooBar do
  import XBS.Target

  def compute, do: :update

  def update do
    outdir = get!(:outdir)
    foo = get!(:foo) |> File.read!()
    bar = get!(:bar) |> File.read!()

    outfile = "#{outdir}/foobar"
    File.write!(outfile, "this is #{foo}#{bar}")
    {:ok, outfile}
  end
end

defmodule XBSTest do
  use ExUnit.Case
  doctest XBS

  alias XBS.Target

  describe "compute/2" do
    test "return basic ok/update info" do
      build =
        XBS.new_build(%{
          foo: %{
            compute: fn -> {:ok, "some result"} end,
            update: fn -> raise "never get here" end
          },
          bar: %{compute: fn -> :update end, update: fn -> raise "never get here" end}
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
            compute: fn -> :update end,
            update: fn -> raise "never get here" end
          },
          bar: %{
            compute: fn -> {:ok, Target.get!(:foo)} end,
            update: fn -> raise "never get here" end
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
