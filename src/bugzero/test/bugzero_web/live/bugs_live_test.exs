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

  describe "selecting a search" do
    setup %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/bugs")

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

      %{view: view}
    end

    test "select first bug by default", %{view: view} do
      assert_push_event(view, "focus_bug", %{id: 1})
      assert has_element?(view, "#bugs")
      assert has_element?(view, "#bugs #bug-1.selected")
    end

    test "keyboard navigation", %{view: view} do
      render_keyup(view, "key_up", %{"key" => "k"})
      assert_push_event(view, "focus_bug", %{id: 2})
      assert has_element?(view, "#bugs #bug-2.selected")

      render_keyup(view, "key_up", %{"key" => "k"})
      assert has_element?(view, "#bugs #bug-2.selected")

      render_keyup(view, "key_up", %{"key" => "j"})
      assert_push_event(view, "focus_bug", %{id: 1})
      assert has_element?(view, "#bugs #bug-1.selected")

      render_keyup(view, "key_up", %{"key" => "j"})
      assert has_element?(view, "#bugs #bug-1.selected")
    end

    test "spacebar opens selected bug", %{view: view} do
      render_keyup(view, "key_up", %{"key" => " "})
      assert_push_event(view, "open_bug", %{id: 1})
    end

    test "r to refresh", %{view: view} do
      # navigate down one to make sure it's a reload
      render_keyup(view, "key_up", %{"key" => "k"})
      assert has_element?(view, "#bugs #bug-2.selected")

      render_keyup(view, "key_up", %{"key" => "r"})
      assert_push_event(view, "focus_bug", %{id: 1})
      assert has_element?(view, "#bugs #bug-1.selected")
    end

    test "ignore other keys", %{view: view} do
      render_keyup(view, "key_up", %{"key" => "`"})
    end
  end
end
