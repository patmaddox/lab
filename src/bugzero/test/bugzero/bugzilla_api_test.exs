defmodule Bugzero.BugzillaApiTest do
  use ExUnit.Case, async: true

  alias Bugzero.BugzillaApi

  setup do
    %{api: BugzillaApi.new("api_token")}
  end

  test "version/0", %{api: api} do
    Req.Test.stub(BugzillaApi, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path == "/bugzilla/rest/version"
      assert conn.params == %{"api_key" => "api_token"}

      Req.Test.json(conn, %{"version" => "5.0.4.1"})
    end)

    assert {:ok, "5.0.4.1"} = BugzillaApi.version(api)
  end
end
