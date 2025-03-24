defmodule BugzeroWeb.PageControllerTest do
  use BugzeroWeb.ConnCase

  alias Bugzero.BugzillaApi

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200)
  end

  test "POST /", %{conn: conn} do
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

    conn = post(conn, ~p"/", %{"email" => "test@example.com", "api_key" => "SECRET"})
    assert redirected_to(conn) =~ "/bugs"

    assert Plug.Conn.get_session(conn, "email") == "test@example.com"
    assert Plug.Conn.get_session(conn, "api_key") == "SECRET"
  end
end
