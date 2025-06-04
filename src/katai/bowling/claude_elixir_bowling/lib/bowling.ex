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

  # 10th frame special handling
  defp score_frames(remaining_rolls, 10, total_score) do
    frame_score = Enum.sum(remaining_rolls)
    total_score + frame_score
  end

  # Regular frames (1-9) - Strike with enough bonus rolls
  defp score_frames([10, next1, next2 | rest], frame, total_score) when frame < 10 do
    frame_score = 10 + next1 + next2
    score_frames([next1, next2 | rest], frame + 1, total_score + frame_score)
  end

  # Regular frames (1-9) - Strike without enough bonus rolls
  defp score_frames([10 | _], frame, total_score) when frame < 10 do
    total_score
  end

  # Regular frames (1-9) - Spare with enough bonus rolls
  defp score_frames([first, second, next | rest], frame, total_score)
       when frame < 10 and first + second == 10 do
    frame_score = 10 + next
    score_frames([next | rest], frame + 1, total_score + frame_score)
  end

  # Regular frames (1-9) - Spare without enough bonus rolls
  defp score_frames([first, second], frame, total_score)
       when frame < 10 and first + second == 10 do
    total_score
  end

  # Regular frames (1-9) - Normal frame
  defp score_frames([first, second | rest], frame, total_score) when frame < 10 do
    frame_score = first + second
    score_frames(rest, frame + 1, total_score + frame_score)
  end

  # Not enough rolls to complete current frame
  defp score_frames(_, _, total_score) do
    total_score
  end
end
