defmodule Bowling do
  @moduledoc """
  Bowling game scorer.
  """

  defstruct score: 0

  @doc """
  Rolls a ball and returns updated Bowling struct with current score.
  """
  def roll(%Bowling{score: current_score} = game, pins) do
    %{game | score: current_score + pins}
  end
end
