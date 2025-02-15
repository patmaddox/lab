defmodule XBS do
  defmodule KeyNotFoundError do
    defexception [:key]

    def message(exception) do
      ":#{exception.key}"
    end
  end

  def compute(%{targets: targets}, store, inputs) do
    big_store = Map.merge(store, inputs)

    targets
    |> Enum.reduce(big_store, fn {k, target}, s ->
      try do
        put(s, k, target.compute.(s))
      rescue
        KeyNotFoundError -> s
      end
    end)
    |> Map.take(Map.keys(targets))
  end

  def new_build(targets) do
    %{targets: targets}
  end

  def get(store, key) do
    Map.get(store, key) || raise KeyNotFoundError, key: key
  end

  def put(store, key, value) do
    Map.put(store, key, value)
  end
end
