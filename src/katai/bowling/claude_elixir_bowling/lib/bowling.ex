defmodule Bowling do
  @moduledoc """
  Bowling game scorer.
  """

  defstruct score: 0, rolls: []

  @doc """
  Rolls a ball and returns updated Bowling struct with current score.
  """
  def roll(%Bowling{rolls: rolls} = game, pins) do
    new_rolls = rolls ++ [pins]
    new_score = calculate_score(new_rolls)
    %{game | score: new_score, rolls: new_rolls}
  end

  defp calculate_score([10, second, third | _]) do
    10 + second + third + second + third
  end

  defp calculate_score([10, _]) do
    0
  end

  defp calculate_score([first, second, third, fourth | _]) when first + second == 10 do
    10 + third + third + fourth
  end

  defp calculate_score([first, second, 10, _]) do
    first + second
  end

  defp calculate_score(rolls) do
    Enum.sum(rolls)
  end
end
