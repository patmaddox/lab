defmodule DocSiteTest do
  use ExUnit.Case
  doctest DocSite

  test "greets the world" do
    assert DocSite.hello() == :world
  end
end
