defmodule BugzeroWeb.BugsLiveTest do
  use BugzeroWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Bugzero.BugzillaApi

  setup %{conn: conn} do
    Req.Test.verify_on_exit!()

    Req.Test.expect(BugzillaApi, fn conn ->
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

    Req.Test.expect(BugzillaApi, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/bugzilla/rest/bug"

      assert conn.params == %{
               "api_key" => "SECRET",
               "limit" => "20",
               "include_fields" => "id,summary,tags",
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

    conn =
      conn
      |> Phoenix.ConnTest.init_test_session(%{})
      |> Plug.Conn.put_session("email", "test@example.com")
      |> Plug.Conn.put_session("api_key", "SECRET")

    %{conn: conn}
  end

  test "selecting a search sets params", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/bugs")

    view
    |> form("#searches", %{selected_search: "foo search"})
    |> render_change()

    assert_patched(view, ~p"/bugs/foo search")
  end

  test "select first bug by default", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/bugs/foo search")

    assert_push_event(view, "focus_bug", %{id: 1})
    assert has_element?(view, "#bugs")
    assert has_element?(view, "#bugs #bug-1.selected")
  end

  test "keyboard navigation", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/bugs/foo search")

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

  test "spacebar opens selected bug", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/bugs/foo search")

    render_keyup(view, "key_up", %{"key" => " "})
    assert_push_event(view, "open_bug", %{id: 1})
  end

  test "r to refresh", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/bugs/foo search")

    # navigate down one to make sure it's a reload
    render_keyup(view, "key_up", %{"key" => "k"})
    assert has_element?(view, "#bugs #bug-2.selected")

    Req.Test.expect(BugzillaApi, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/bugzilla/rest/bug"

      assert conn.params == %{
               "api_key" => "SECRET",
               "limit" => "20",
               "include_fields" => "id,summary,tags",
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

    render_keyup(view, "key_up", %{"key" => "r"})
    assert_push_event(view, "focus_bug", %{id: 1})
    assert has_element?(view, "#bugs #bug-1.selected")
  end

  test "ignore other keys", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/bugs/foo search")

    render_keyup(view, "key_up", %{"key" => "`"})
  end

  describe "ignore" do
    setup do
      Req.Test.expect(BugzillaApi, fn conn ->
        json = %{
          "id" => "update_tags_123",
          "method" => "Bug.update_tags",
          "params" => [
            %{
              "Bugzilla_api_key" => "SECRET",
              "ids" => [123],
              "tags" => %{"add" => ["ignore"]}
            }
          ]
        }

        assert conn.method == "POST"
        assert conn.request_path == "/bugzilla/jsonrpc.cgi"
        assert conn.params == %{}

        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == JSON.encode!(json)

        Req.Test.json(conn, %{})
      end)

      :ok
    end

    test "i to ignore", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/bugs/foo search")

      render_keyup(view, "key_up", %{"key" => "i"})
      assert has_element?(view, "#bugs #bug-1.selected.ignored")

      # moving doesn't clear ignore status
      render_keyup(view, "key_up", %{"key" => "k"})
      assert has_element?(view, "#bugs #bug-1.ignored")
    end
  end

  describe "subscribe" do
    setup do
      Req.Test.expect(BugzillaApi, fn conn ->
        json_body = JSON.encode!(%{"cc" => %{"add" => ["test@example.com"]}})

        assert conn.method == "PUT"
        assert conn.request_path == "/bugzilla/rest/bug/123"
        assert conn.params == %{"api_key" => "SECRET"}

        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == json_body

        Req.Test.json(conn, %{})
      end)

      :ok
    end

    test "s to subscribe", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/bugs/foo search")

      render_keyup(view, "key_up", %{"key" => "s"})
      assert has_element?(view, "#bugs #bug-1.selected.subscribed")
    end
  end
end
