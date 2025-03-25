defmodule Bugzero.BugzillaApi do
  defstruct [:email, :api_key, :searches]

  @bugzilla_url "https://bugs.freebsd.org/bugzilla"
  @num_search_results 10

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

  def fetch_searches(api) do
    %Response{status: 200, body: %{"users" => [%{"saved_searches" => searches}]}} =
      api
      |> json_req()
      |> Req.get!(url: "/user/#{api.email}")

    searches =
      Enum.reduce(searches, %{}, fn s, acc ->
        name = Map.fetch!(s, "name")
        vals = Map.take(s, ~w(name query))
        Map.put(acc, name, vals)
      end)

    {:ok, %{api | searches: searches}}
  end

  def search(api, search_name) do
    search(api, search_name, @num_search_results)
  end

  def search(%__MODULE__{searches: nil}, _search_name, _limit) do
    {:error, :searches_not_loaded}
  end

  def search(%__MODULE__{searches: searches}, search_name, _limit)
      when not is_map_key(searches, search_name) do
    {:error, :unknown_search}
  end

  def search(api = %__MODULE__{searches: searches}, search_name, limit) do
    query =
      searches
      |> Map.fetch!(search_name)
      |> Map.fetch!("query")

    %Response{status: 200, body: %{"bugs" => bugs}} =
      api
      |> json_req()
      |> Req.get!(url: "bug?limit=#{limit}&include_fields=_default,tags&#{query}")

    {:ok, Enum.map(bugs, &parse_bug/1)}
  end

  defp parse_bug(bug) do
    %{
      id: Map.fetch!(bug, "id"),
      summary: Map.fetch!(bug, "summary"),
      tags: Map.fetch!(bug, "tags")
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
    |> Req.Request.put_header("cache-control", "no-cache")
  end
end
