defmodule BugzeroWeb.BugsLive do
  use Phoenix.LiveView

  import BugzeroWeb.CoreComponents

  alias Bugzero.BugzillaApi

  def handle_params(_params, _uri, socket) do
    socket =
      socket
      |> assign(:auth_form, to_form(%{}))
      |> assign(:search_form, to_form(%{}))
      |> assign(:bugs, [])
      |> assign(:searches, [])

    {:noreply, socket}
  end

  def handle_event("auth", %{"api_key" => api_key, "email" => email}, socket) do
    {:ok, api} =
      BugzillaApi.new(email: email, api_key: api_key)
      |> BugzillaApi.fetch_searches()

    searches = searches(api)

    search_names =
      searches
      |> Enum.map(&Map.fetch!(&1, "name"))
      |> Enum.sort()

    socket =
      socket
      |> assign(:api, api)
      |> assign(:searches, searches)
      |> assign(:search_names, search_names)

    {:noreply, socket}
  end

  def handle_event("select_search", %{"selected_search" => selected_search}, socket) do
    search_form = Map.put(socket.assigns.search_form, "selected_search", selected_search)
    {:ok, bugs} = BugzillaApi.search(socket.assigns.api, selected_search)

    socket =
      socket
      |> assign(:search_form, search_form)
      |> assign(:bugs, bugs)

    {:noreply, socket}
  end

  defp searches(api) do
    Map.values(api.searches)
  end
end
