defmodule BugzeroWeb.BugsLiveTest do
  use BugzeroWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Bugzero.BugzillaApi

  setup %{conn: conn} do
    Req.Test.stub(BugzillaApi, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/bugzilla/rest/user/test@example.com"
      assert conn.params == %{"api_key" => "SECRET"}

      Req.Test.json(conn, %{
        "users" => [
          %{
            "saved_searches" => [
              %{"name" => "foo search", "query" => "foo=bar&baz=qux", "ignore" => "this"}
            ]
          }
        ]
      })
    end)

    conn =
      conn
      |> Phoenix.ConnTest.init_test_session(%{})
      |> Plug.Conn.put_session("email", "test@example.com")
      |> Plug.Conn.put_session("api_key", "SECRET")

    %{conn: conn}
  end

  test "select search shows bugs", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/bugs")

    assert has_element?(view, "#searches")

    Req.Test.stub(BugzillaApi, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/bugzilla/rest/bug"

      assert conn.params == %{
               "api_key" => "SECRET",
               "limit" => "10",
               "include_fields" => "_default,tags",
               "foo" => "bar",
               "baz" => "qux"
             }

      Req.Test.json(conn, %{
        "bugs" => [
          %{"id" => 1, "summary" => "bug 1", "tags" => []},
          %{"id" => 2, "summary" => "bug 2", "tags" => ["tag1"]}
        ]
      })
    end)

    view
    |> form("#searches", %{selected_search: "foo search"})
    |> render_change()

    assert has_element?(view, "#bugs")
  end
end
