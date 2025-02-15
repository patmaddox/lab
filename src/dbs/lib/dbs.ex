defmodule DBS do
  def get(build, store, inputs) do
    build
    |> Enum.reduce(Map.merge(store, inputs), fn {k, task}, s ->
      Map.put_new_lazy(s, k, fn -> task.(s) end)
    end)
    |> Map.take(Map.keys(build))
  end
end
