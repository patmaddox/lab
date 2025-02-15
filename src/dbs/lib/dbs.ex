defmodule DBS do
  def build(%{targets: targets}, store, inputs) do
    targets
    |> Enum.reduce(Map.merge(store, inputs), fn {k, task}, s ->
      Map.put_new_lazy(s, k, fn -> task.(s) end)
    end)
    |> Map.take(Map.keys(targets))
  end

  def new_build(targets) do
    %{targets: targets}
  end

  def new_store(store \\ %{}) do
    store
  end

  def get(store, key) do
    Map.get(store, key) || raise "unable to resolve :#{key}"
  end
end
