defmodule Bugzero.BugzillaApi do
  defstruct [:api_key]

  alias Req.Response

  def new(api_key) do
    %__MODULE__{api_key: api_key}
  end

  def version(api) do
    [
      base_url: "https://bugs.freebsd.org/bugzilla/rest",
      params: [api_key: api.api_key]
    ]
    |> Keyword.merge(Application.fetch_env!(:bugzero, :bugzilla_api_options))
    |> Req.new()
    |> Req.Request.put_header("accept", "application/json")
    |> Req.Request.put_header("content-type", "application/json")
    |> Req.get!(url: "/version")
    |> case do
      %Response{status: 200, body: %{"version" => version}} -> {:ok, version}
    end
  end
end
