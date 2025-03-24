defmodule Bugzero.BugzillaApi do
  defstruct [:email, :api_key]

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

  defp parse_bug(bug) do
    %{
      id: Map.fetch!(bug, "id"),
      tags: Map.fetch!(bug, "tags"),
      summary: Map.fetch!(bug, "summary")
    }
  end

  defp json_req(%__MODULE__{api_key: api_key}) do
    [
      base_url: "https://bugs.freebsd.org/bugzilla/rest",
      params: [api_key: api_key]
    ]
    |> Keyword.merge(Application.fetch_env!(:bugzero, :bugzilla_api_options))
    |> Req.new()
    |> Req.Request.put_header("accept", "application/json")
    |> Req.Request.put_header("content-type", "application/json")
  end
end
