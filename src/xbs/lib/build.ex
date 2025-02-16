defmodule XBS.Build do
  alias XBS.{Store, KeyNotFoundError, NeedsUpdateError}

  def new(tasks) do
    %{tasks: tasks}
  end

  def compute(build, inputs) do
    store = Store.new(inputs)
    Enum.each(build.tasks, fn {k, t} -> Store.add_task(store, k, t) end)

    Enum.reduce(build.tasks, %{ok: [], update: []}, fn {k, _v}, acc ->
      try do
        Store.get(store, k)
        %{acc | ok: [k | acc.ok]}
      rescue
        KeyNotFoundError ->
          %{acc | update: [k | acc.update]}

        NeedsUpdateError ->
          %{acc | update: [k | acc.update]}
      end
    end)
  end

  def update(build, inputs) do
    store = Store.new(inputs, :update)
    Enum.each(build.tasks, fn {k, t} -> Store.add_task(store, k, t) end)

    Enum.each(build.tasks, fn {k, _t} ->
      XBS.Store.get(store, k)
    end)
  end
end
