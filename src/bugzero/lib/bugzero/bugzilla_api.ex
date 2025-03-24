defmodule Bugzero.BugzillaApi do
  defstruct [:email, :api_key]

  @bugzilla_url "https://bugs.freebsd.org/bugzilla"

  alias Req.Response

  def new(attrs) do
    struct(__MODULE__, attrs)
  end

  def version(api) do
    %Response{status: 200, body: %{"version" => version}} =
      api
      |> json_req()
      |> Req.get!(url: "/version")

    {:ok, version}
  end

  def bug(api, id) do
    %Response{status: 200, body: %{"bugs" => [bug]}} =
      api
      |> json_req()
      |> Req.get!(url: "/bug/#{id}?include_fields=_default,tags")

    {:ok, parse_bug(bug)}
  end

  def subscribe(api, id) do
    %Response{status: 200} =
      api
      |> json_req()
      |> Req.put!(
        url: "/bug/#{id}",
        body: JSON.encode!(%{"cc" => %{"add" => [api.email]}})
      )

    :ok
  end

  def ignore(api, id) do
    %Response{status: 200} =
      [base_url: "#{@bugzilla_url}/jsonrpc.cgi"]
      |> bugzilla_req()
      |> Req.post!(
        body:
          JSON.encode!(%{
            "id" => "update_tags_#{id}",
            "method" => "Bug.update_tags",
            "params" => [
              %{
                "Bugzilla_api_key" => api.api_key,
                "ids" => [id],
                "tags" => %{"add" => ["ignore"]}
              }
            ]
          })
      )

    :ok
  end

  defp parse_bug(bug) do
    %{
      id: Map.fetch!(bug, "id"),
      tags: Map.fetch!(bug, "tags"),
      summary: Map.fetch!(bug, "summary")
    }
  end

  defp json_req(%__MODULE__{api_key: api_key}) do
    [
      base_url: "#{@bugzilla_url}/rest",
      params: [api_key: api_key]
    ]
    |> bugzilla_req()
  end

  def bugzilla_req(options) do
    options
    |> Keyword.merge(Application.fetch_env!(:bugzero, :bugzilla_api_options))
    |> Req.new()
    |> Req.Request.put_header("accept", "application/json")
    |> Req.Request.put_header("content-type", "application/json")
  end
end
