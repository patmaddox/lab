defmodule XBS.Target do
  use GenServer

  def get(store, key) do
    XBS.Store.get(store, key)
  end

  def get!(name) do
    # it would be nice to catch the exception from GenServer.call
    # instead of using GenServer.whereis, but I'm not sure what the
    # exception is
    if !GenServer.whereis(name) do
      throw({:error, {:key_not_found, name}})
    end

    case Process.get(:mode) do
      :compute ->
        case compute(name) do
          {:ok, result} ->
            result

          :update ->
            throw({:error, {:needs_update, name}})
        end

      :update ->
        {:ok, result} = update(name)
        result
    end
  end

  def new(name, props) when is_map(props) do
    GenServer.start_link(__MODULE__, props, name: name)
  end

  def new(name, module) do
    new(name, %{compute: &module.compute/0, update: &module.update/0})
  end

  def init(props) do
    {:ok, props}
  end

  def compute(name) do
    GenServer.call(name, :compute)
  end

  def update(name) do
    GenServer.call(name, :update)
  end

  def handle_call(:compute, _from, state = %{result: result}) do
    {:reply, result, state}
  end

  def handle_call(:compute, _from, state) do
    Process.put(:mode, :compute)

    result =
      try do
        state.compute.()
      catch
        {:error, {reason, _}} when reason in [:key_not_found, :needs_update] -> :update
      end

    {:reply, result, Map.put(state, :result, result)}
  end

  def handle_call(:update, _from, state = %{result: result}) when result != :update do
    {:reply, result, state}
  end

  def handle_call(:update, _from, state) do
    Process.put(:mode, :update)

    result =
      try do
        state.update.()
      catch
        e = {:error, {:key_not_found, _}} -> e
      end

    {:reply, result, Map.put(state, :result, result)}
  end
end
