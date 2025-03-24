defmodule BugzeroWeb.BugsLiveTest do
  use BugzeroWeb.ConnCase

  import Phoenix.LiveViewTest

  test "GET /", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/bugs")

    assert html =~ "hello"
  end
end
