defmodule BugzeroWeb.BugsLive do
  use Phoenix.LiveView

  import BugzeroWeb.CoreComponents

  alias Bugzero.BugzillaApi

  def mount(_params, session, socket) do
    socket =
      socket
      |> assign(:search_form, to_form(%{}))
      |> assign(:bugs, [])
      |> assign(:search_names, [])

    if connected?(socket) do
      {:ok, load_api(session, socket)}
    else
      {:ok, socket}
    end
  end

  def handle_params(params, uri, socket) do
    if connected?(socket) do
      handle_params(params, uri, socket, socket.assigns.live_action)
    else
      {:noreply, socket}
    end
  end

  def handle_params(_params, _uri, socket, :index) do
    {:noreply, socket}
  end

  def handle_params(%{"search" => selected_search}, _uri, socket, :search) do
    search_form = Map.put(socket.assigns.search_form, "selected_search", selected_search)

    socket =
      socket
      |> assign(:search_form, search_form)
      |> assign(:selected_search, selected_search)
      |> refresh_bugs()

    {:noreply, socket}
  end

  def handle_event("select_search", %{"selected_search" => selected_search}, socket) do
    socket = push_patch(socket, to: "/bugs/#{URI.encode(selected_search)}")
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

  defp load_api(%{"api_key" => api_key, "email" => email}, socket) do
    {:ok, api} =
      BugzillaApi.new(email: email, api_key: api_key)
      |> BugzillaApi.fetch_searches()

    search_names =
      api.searches
      |> Map.keys()
      |> Enum.sort()

    socket
    |> assign(:api, api)
    |> assign(:search_names, search_names)
  end

  defp assign_current_bug(socket, new_index) do
    current_bug =
      socket
      |> current_bug()
      |> remove_css_class("selected")

    new_bug =
      socket
      |> bug_at(new_index)
      |> add_css_class("selected")

    socket
    |> update_current_bug(current_bug)
    |> update_bug_at(new_index, new_bug)
    |> assign(:current_bug_index, new_index)
    |> push_event("focus_bug", %{id: new_bug.id})
  end

  defp refresh_bugs(socket) do
    {:ok, bugs} = BugzillaApi.search(socket.assigns.api, socket.assigns.selected_search, 20)
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

  defp ignore_current_bug(socket) do
    bug =
      socket
      |> current_bug()
      |> add_css_class("ignored")

    Task.start_link(fn ->
      :ok = BugzillaApi.ignore(socket.assigns.api, bug.id)
    end)

    update_current_bug(socket, bug)
  end

  defp subscribe_current_bug(socket) do
    bug =
      socket
      |> current_bug()
      |> add_css_class("subscribed")

    Task.start_link(fn ->
      :ok = BugzillaApi.subscribe(socket.assigns.api, bug.id)
    end)

    update_current_bug(socket, bug)
  end

  defp add_css_class(bug, css_class) do
    %{bug | css_classes: MapSet.put(bug.css_classes, css_class)}
  end

  defp remove_css_class(bug, css_class) do
    %{bug | css_classes: MapSet.delete(bug.css_classes, css_class)}
  end

  defp bug_at(socket, index) do
    Enum.at(socket.assigns.bugs, index)
  end

  defp current_bug(socket) do
    bug_at(socket, socket.assigns.current_bug_index)
  end

  defp update_bug_at(socket, index, bug) do
    bugs = List.replace_at(socket.assigns.bugs, index, bug)
    assign(socket, :bugs, bugs)
  end

  defp update_current_bug(socket, bug) do
    update_bug_at(socket, socket.assigns.current_bug_index, bug)
  end
end
