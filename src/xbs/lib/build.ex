defmodule XBS.Build do
  alias XBS.Target

  def new(targets) do
    %{targets: targets}
  end

  def compute(build, inputs) do
    init_inputs(inputs)
    init_targets(build)

    build.targets
    |> Map.keys()
    |> Enum.reduce(%{ok: [], update: []}, fn k, acc ->
      case Target.compute(k) do
        {:ok, _} -> %{acc | ok: [k | acc.ok]}
        :update -> %{acc | update: [k | acc.update]}
      end
    end)
  end

  def update(build, inputs) do
    compute(build, inputs)

    build.targets
    |> Map.keys()
    |> Enum.each(fn k ->
      {:ok, _result} = Target.update(k)
    end)

    :ok
  end

  def init_inputs(inputs) do
    Enum.each(inputs, fn {k, v} ->
      result_fn = fn -> {:ok, v} end
      {:ok, _} = Target.new(k, %{compute: result_fn, update: result_fn})
    end)
  end

  def init_targets(%{targets: targets}) do
    Enum.each(targets, fn {k, t} -> {:ok, _} = Target.new(k, t) end)
  end
end
