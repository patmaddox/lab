defmodule DBS do
  def compute(%{targets: targets}, store, inputs) do
    big_store = Map.merge(store, inputs)

    targets
    |> Enum.reduce(big_store, fn {k, target}, s ->
      if has_all_inputs?(big_store, target) do
        Map.put(s, k, target.compute.(s))
      else
        s
      end
    end)
    |> Map.take(Map.keys(targets))
  end

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

  defp has_all_inputs?(store, %{inputs: inputs}) do
    Enum.all?(inputs, fn i -> Map.has_key?(store, i) end)
  end
end
