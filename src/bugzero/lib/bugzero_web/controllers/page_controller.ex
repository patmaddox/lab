defmodule BugzeroWeb.PageController do
  use BugzeroWeb, :controller

  alias Bugzero.BugzillaApi

  def home(conn, _params) do
    conn =
      conn
      |> assign(:auth_form, %{})

    render(conn, :home, layout: false)
  end

  def auth(conn, %{"email" => email, "api_key" => api_key}) do
    {:ok, _api} =
      BugzillaApi.new(email: email, api_key: api_key)
      |> BugzillaApi.fetch_searches()

    conn =
      conn
      |> Plug.Conn.put_session("email", email)
      |> Plug.Conn.put_session("api_key", api_key)

    redirect(conn, to: ~p"/bugs")
  end
end
