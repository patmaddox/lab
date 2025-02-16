defmodule XBS.Build do
  alias XBS.{Store, KeyNotFoundError}

  def new(tasks) do
    %{tasks: tasks}
  end

  def calculate(build, inputs) do
    store = Store.new(inputs)
    Enum.each(build.tasks, fn {k, t} -> Store.add_task(store, k, t.calculate) end)

    Enum.reduce(build.tasks, %{}, fn {k, _v}, acc ->
      try do
        Map.put(acc, k, Store.get(store, k))
      rescue
        KeyNotFoundError -> acc
      end
    end)
  end
end

