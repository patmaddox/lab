defmodule XBS.Build do
  alias XBS.{Store, KeyNotFoundError, NeedsUpdateError}

  def new(targets) do
    %{targets: targets}
  end

  def compute(build, inputs) do
    store = Store.new(inputs)
    Enum.each(build.targets, fn {k, t} -> Store.add_target(store, k, t) end)

    Enum.reduce(build.targets, %{ok: [], update: []}, fn {k, _v}, acc ->
      try do
        Store.get(store, k)
        %{acc | ok: [k | acc.ok]}
      rescue
        KeyNotFoundError ->
          %{acc | update: [k | acc.update]}

        NeedsUpdateError ->
          %{acc | update: [k | acc.update]}
      end
    end)
  end

  def update(build, inputs) do
    store = Store.new(inputs, :update)
    Enum.each(build.targets, fn {k, t} -> Store.add_target(store, k, t) end)

    Enum.each(build.targets, fn {k, _t} ->
      XBS.Store.get(store, k)
    end)
  end
end
