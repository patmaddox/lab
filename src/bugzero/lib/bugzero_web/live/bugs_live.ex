defmodule BugzeroWeb.BugsLive do
  use Phoenix.LiveView

  import BugzeroWeb.CoreComponents

  alias Bugzero.BugzillaApi

  def mount(_params, session, socket) do
    if connected?(socket) do
      socket = assign(socket, :api, api(session))
      {:ok, socket}
    else
      {:ok, socket}
    end
  end

  def handle_params(_params, _uri, socket) do
    socket =
      socket
      |> assign(:search_form, to_form(%{}))
      |> assign(:bugs, [])
      |> assign(:search_names, [])

    if connected?(socket) do
      search_names =
        socket.assigns.api.searches
        |> Map.keys()
        |> Enum.sort()

      socket = assign(socket, :search_names, search_names)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("select_search", %{"selected_search" => selected_search}, socket) do
    search_form = Map.put(socket.assigns.search_form, "selected_search", selected_search)
    {:ok, bugs} = BugzillaApi.search(socket.assigns.api, selected_search)

    socket =
      socket
      |> assign(:search_form, search_form)
      |> assign(:bugs, bugs)
      |> assign_current_bug_index(0)

    {:noreply, socket}
  end

  def handle_event("key_up", %{"key" => "k"}, socket) do
    current_bug_index = socket.assigns.current_bug_index + 1

    if current_bug_index == length(socket.assigns.bugs) do
      {:noreply, socket}
    else
      {:noreply, assign_current_bug_index(socket, current_bug_index)}
    end
  end

  def handle_event("key_up", %{"key" => "j"}, socket) do
    current_bug_index = socket.assigns.current_bug_index

    if current_bug_index == 0 do
      {:noreply, socket}
    else
      current_bug_index = current_bug_index - 1
      {:noreply, assign_current_bug_index(socket, current_bug_index)}
    end
  end

  def handle_event("key_up", %{"key" => " "}, socket) do
    bug_id = Enum.at(socket.assigns.bugs, socket.assigns.current_bug_index).id
    {:noreply, push_event(socket, "open_bug", %{id: bug_id})}
  end

  def handle_event("key_up", %{"key" => _}, socket), do: {:noreply, socket}

  defp api(%{"api_key" => api_key, "email" => email}) do
    {:ok, api} =
      BugzillaApi.new(email: email, api_key: api_key)
      |> BugzillaApi.fetch_searches()

    api
  end

  defp assign_current_bug_index(socket, index) do
    bug_id = Enum.at(socket.assigns.bugs, index).id

    socket
    |> assign(:current_bug_index, index)
    |> push_event("focus_bug", %{id: bug_id})
  end
end
