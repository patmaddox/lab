defmodule XBS.Target do
  use GenServer

  alias XBS.{KeyNotFoundError, NeedsUpdateError}

  def get(store, key) do
    XBS.Store.get(store, key)
  end

  def get!(name) do
    # it would be nice to catch the exception from GenServer.call
    # instead of using GenServer.whereis, but I'm not sure what the
    # exception is
    if GenServer.whereis(name) do
      case compute(name) do
        {:ok, result} -> result
        :update -> raise NeedsUpdateError, key: name
      end
    else
      raise KeyNotFoundError, key: name
    end
  end

  def new(name, props) when is_map(props) do
    state =
      props
      |> Map.put(:state, :init)
      |> Map.put(:result, nil)

    GenServer.start_link(__MODULE__, state, name: name)
  end

  def new(name, module) do
    new(name, %{compute: &module.compute/0})
  end

  def init(props) do
    {:ok, props}
  end

  def compute(name) do
    GenServer.call(name, :compute)
  end

  def handle_call(:compute, _from, state = %{state: :init}) do
    result =
      try do
        state.compute.()
      rescue
        KeyNotFoundError -> :update
        NeedsUpdateError -> :update
      end

    {:reply, result, %{state | state: :computed, result: result}}
  end

  def handle_call(:compute, _from, state = %{state: :computed}) do
    {:reply, state.result, state}
  end
end
