defmodule XBS do
  defmodule KeyNotFoundError do
    defexception [:key]

    def message(exception) do
      ":#{exception.key}"
    end
  end

  def compute(tasks, store, inputs) do
    big_store = Map.merge(store, inputs)

    tasks
    |> Enum.reduce(big_store, fn {k, t}, s ->
      try do
        put(s, k, t.compute.(s))
      rescue
        KeyNotFoundError -> s
      end
    end)
    |> Map.take(Map.keys(tasks))
  end

  def get(store, key) do
    Map.get(store, key) || raise KeyNotFoundError, key: key
  end

  def put(store, key, value) do
    Map.put(store, key, value)
  end
end
