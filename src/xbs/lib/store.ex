defmodule XBS.Store do
  def new(state \\ %{}, mode \\ :compute) do
    store = :ets.new(__MODULE__, [:set, :protected])
    :ets.insert(store, {:__xbs_mode, mode})
    Enum.each(state, fn {k, v} -> :ets.insert(store, {k, :val, v}) end)
    store
  end

  def get(store, key) do
    case :ets.lookup(store, key) do
      [] ->
        raise XBS.KeyNotFoundError, key: key

      [{^key, :val, val}] ->
        val

      [{^key, :task, task}] ->
        {:ok, result} = compute_result(key, task, store)
        :ets.insert(store, {key, :val, result})
        result
    end
  end

  def add_task(store, key, task) do
    :ets.insert(store, {key, :task, task})
  end

  def compute_result(key, task, store) when is_map(task) do
    compute_result(key, task.compute, task.update, store)
  end

  def compute_result(key, task, store) do
    compute_result(key, &task.compute/1, &task.update/1, store)
  end

  def compute_result(key, compute_fn, update_fn, store) do
    case compute_fn.(store) do
      {:ok, result} ->
        {:ok, result}

      :update ->
        if update_mode?(store) do
          update_fn.(store)
        else
          raise XBS.NeedsUpdateError, key: key
        end
    end
  end

  defp update_mode?(store) do
    [{:__xbs_mode, mode}] = :ets.lookup(store, :__xbs_mode)
    mode == :update
  end
end
