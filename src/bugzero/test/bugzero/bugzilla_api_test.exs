defmodule Bugzero.BugzillaApiTest do
  use ExUnit.Case, async: true

  alias Bugzero.BugzillaApi

  setup do
    %{api: BugzillaApi.new(email: "test@example.com", api_key: "SECRET")}
  end

  test "version/1" do
    api = BugzillaApi.new(%{api_key: "SECRET"})

    Req.Test.stub(BugzillaApi, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/bugzilla/rest/version"
      assert conn.params == %{"api_key" => "SECRET"}

      Req.Test.json(conn, %{"version" => "5.0.4.1"})
    end)

    assert {:ok, "5.0.4.1"} = BugzillaApi.version(api)
  end

  test "bug/2", %{api: api} do
    Req.Test.stub(BugzillaApi, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/bugzilla/rest/bug/123"
      assert conn.params == %{"api_key" => "SECRET", "include_fields" => "_default,tags"}

      bug_resp = %{
        "id" => 123,
        "tags" => ["tag1", "tag2"],
        "summary" => "bug summary"
      }

      Req.Test.json(conn, %{"bugs" => [bug_resp]})
    end)

    assert {:ok, bug} = BugzillaApi.bug(api, 123)
    assert bug.id == 123
    assert bug.tags == ["tag1", "tag2"]
    assert bug.summary == "bug summary"
  end

  test "subscribe/2", %{api: api} do
    Req.Test.stub(BugzillaApi, fn conn ->
      json_body = JSON.encode!(%{"cc" => %{"add" => ["test@example.com"]}})

      assert conn.method == "PUT"
      assert conn.request_path == "/bugzilla/rest/bug/123"
      assert conn.params == %{"api_key" => "SECRET"}

      {:ok, body, conn} = Plug.Conn.read_body(conn)
      assert body == json_body

      Req.Test.json(conn, %{})
    end)

    assert :ok = BugzillaApi.subscribe(api, 123)
  end

  test "ignore/2", %{api: api} do
    Req.Test.stub(BugzillaApi, fn conn ->
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

    assert :ok = BugzillaApi.ignore(api, 123)
  end

  test "fetch_searches/1", %{api: api} do
    Req.Test.stub(BugzillaApi, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/bugzilla/rest/user/test@example.com"
      assert conn.params == %{"api_key" => "SECRET"}

      Req.Test.json(conn, %{
        "users" => [
          %{
            "saved_searches" => [
              %{"name" => "search 1", "query" => "foo=bar", "ignore" => "this"},
              %{"name" => "search 2", "query" => "bar=baz", "ignore" => "that"}
            ]
          }
        ]
      })
    end)

    assert {:ok, api} = BugzillaApi.fetch_searches(api)

    assert api.searches == %{
             "search 1" => %{"name" => "search 1", "query" => "foo=bar"},
             "search 2" => %{"name" => "search 2", "query" => "bar=baz"}
           }
  end

  describe "search/2" do
    setup %{api: api} do
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

      {:ok, api} = BugzillaApi.fetch_searches(api)
      %{api: api}
    end

    test "error when searches not loaded" do
      api = BugzillaApi.new(api_key: "foobar")
      assert {:error, :searches_not_loaded} = BugzillaApi.search(api, "foo")
    end

    test "error when search is unknown", %{api: api} do
      assert {:error, :unknown_search} = BugzillaApi.search(api, "unknown")
    end

    test "perform search", %{api: api} do
      Req.Test.stub(BugzillaApi, fn conn ->
        assert conn.method == "GET"
        assert conn.request_path == "/bugzilla/rest/bug"

        assert conn.params == %{
                 "api_key" => "SECRET",
                 "limit" => "10",
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

      assert {:ok, [bug1, bug2]} = BugzillaApi.search(api, "foo search")
      assert %{id: 1, summary: "bug 1", tags: []} = bug1
      assert %{id: 2, summary: "bug 2", tags: ["tag1"]} = bug2
    end
  end
end
