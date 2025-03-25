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

    socket =
      socket
      |> assign(:search_form, search_form)
      |> assign(:selected_search, selected_search)
      |> refresh_bugs()

    {:noreply, socket}
  end

  def handle_event("key_up", %{"key" => "k"}, socket) do
    {:noreply, next_bug(socket)}
  end

  def handle_event("key_up", %{"key" => "j"}, socket) do
    {:noreply, prev_bug(socket)}
  end

  def handle_event("key_up", %{"key" => " "}, socket) do
    bug_id = Enum.at(socket.assigns.bugs, socket.assigns.current_bug_index).id
    {:noreply, push_event(socket, "open_bug", %{id: bug_id})}
  end

  def handle_event("key_up", %{"key" => "r"}, socket) do
    {:noreply, refresh_bugs(socket)}
  end

  def handle_event("key_up", %{"key" => "i"}, socket) do
    {:noreply, ignore_current_bug(socket)}
  end

  def handle_event("key_up", %{"key" => "s"}, socket) do
    {:noreply, subscribe_current_bug(socket)}
  end

  def handle_event("key_up", %{"key" => _}, socket), do: {:noreply, socket}

  defp api(%{"api_key" => api_key, "email" => email}) do
    {:ok, api} =
      BugzillaApi.new(email: email, api_key: api_key)
      |> BugzillaApi.fetch_searches()

    api
  end

  defp assign_current_bug(socket, new_index) do
    bugs = socket.assigns.bugs
    current_index = socket.assigns.current_bug_index
    current_bug = Enum.at(bugs, current_index)

    current_bug =
      Map.put(current_bug, :css_classes, MapSet.delete(current_bug.css_classes, "selected"))

    new_bug = Enum.at(bugs, new_index)

    new_bug =
      Map.put(new_bug, :css_classes, MapSet.put(new_bug.css_classes, "selected"))

    bugs =
      bugs
      |> List.replace_at(current_index, current_bug)
      |> List.replace_at(new_index, new_bug)

    socket
    |> assign(:bugs, bugs)
    |> assign(:current_bug_index, new_index)
    |> push_event("focus_bug", %{id: new_bug.id})
  end

  defp refresh_bugs(socket) do
    {:ok, bugs} = BugzillaApi.search(socket.assigns.api, socket.assigns.selected_search)
    bugs = Enum.map(bugs, &Map.put(&1, :css_classes, MapSet.new()))

    socket
    |> assign(:current_bug_index, 0)
    |> assign(:bugs, bugs)
    |> assign_current_bug(0)
  end

  defp next_bug(socket) do
    index = socket.assigns.current_bug_index + 1

    if index == length(socket.assigns.bugs) do
      socket
    else
      assign_current_bug(socket, index)
    end
  end

  defp prev_bug(socket) do
    index = socket.assigns.current_bug_index

    if index == 0 do
      socket
    else
      assign_current_bug(socket, index - 1)
    end
  end

  defp ignore_current_bug(socket), do: add_current_bug_css_class(socket, "ignored")
  defp subscribe_current_bug(socket), do: add_current_bug_css_class(socket, "subscribed")

  defp add_current_bug_css_class(socket, css_class) do
    bugs = socket.assigns.bugs
    index = socket.assigns.current_bug_index

    bug = Enum.at(bugs, index)
    bug = %{bug | css_classes: MapSet.put(bug.css_classes, css_class)}

    assign(socket, :bugs, List.replace_at(bugs, index, bug))
  end
end
