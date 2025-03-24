defmodule Bugzero.BugzillaApiTest do
  use ExUnit.Case, async: true

  alias Bugzero.BugzillaApi

  setup do
    %{api: BugzillaApi.new("api_token")}
  end

  test "version/1", %{api: api} do
    Req.Test.stub(BugzillaApi, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/bugzilla/rest/version"
      assert conn.params == %{"api_key" => "api_token"}

      Req.Test.json(conn, %{"version" => "5.0.4.1"})
    end)

    assert {:ok, "5.0.4.1"} = BugzillaApi.version(api)
  end

  test "bug/2", %{api: api} do
    Req.Test.stub(BugzillaApi, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/bugzilla/rest/bug/123"
      assert conn.params == %{"api_key" => "api_token", "include_fields" => "_default,tags"}

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
end
