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

  defp calculate_score(rolls) do
    score_frames(rolls, 1, 0)
  end

  defp score_frames(rolls, frame, total_score) when frame <= 10 do
    case score_frame(rolls, frame) do
      {frame_score, remaining_rolls} ->
        score_frames(remaining_rolls, frame + 1, total_score + frame_score)

      :incomplete ->
        total_score
    end
  end

  defp score_frames(_, _, total_score) do
    total_score
  end

  # Strike with enough bonus rolls
  defp score_frame([10, next1, next2 | rest], _frame) do
    {10 + next1 + next2, [next1, next2 | rest]}
  end

  # Spare with enough bonus rolls
  defp score_frame([first, second, next | rest], _frame) when first + second == 10 do
    {10 + next, [next | rest]}
  end

  # Regular frame
  defp score_frame([first, second | rest], _frame) when first + second < 10 do
    {first + second, rest}
  end

  # Incomplete frame
  defp score_frame(_, _) do
    :incomplete
  end
end
