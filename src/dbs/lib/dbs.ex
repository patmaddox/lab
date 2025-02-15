defmodule DBS do
  def build(build, store, inputs) do
    build
    |> Enum.reduce(Map.merge(store, inputs), fn {k, task}, s ->
      Map.put_new_lazy(s, k, fn -> task.(s) end)
    end)
    |> Map.take(Map.keys(build))
  end

  def new_store(store \\ %{}) do
    store
  end

  def get(store, key) do
    Map.get(store, key)
  end
end
