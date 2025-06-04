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
    score_frames(rolls, 1, 0, 0)
  end

  # Finished all 10 frames
  defp score_frames(_rolls, frame, _roll_index, total_score) when frame > 10 do
    total_score
  end

  # 10th frame special handling
  defp score_frames(rolls, 10, roll_index, total_score) do
    remaining_rolls = Enum.drop(rolls, roll_index)
    frame_score = Enum.sum(remaining_rolls)
    total_score + frame_score
  end

  # Regular frames (1-9)
  defp score_frames(rolls, frame, roll_index, total_score) do
    case Enum.slice(rolls, roll_index, 3) do
      [10 | _] ->
        # Strike
        next_two = Enum.slice(rolls, roll_index + 1, 2)

        if length(next_two) < 2 do
          # Can't calculate bonus yet
          total_score
        else
          frame_score = 10 + Enum.sum(next_two)
          score_frames(rolls, frame + 1, roll_index + 1, total_score + frame_score)
        end

      [first, second | _] when first + second == 10 ->
        # Spare
        next_one = Enum.slice(rolls, roll_index + 2, 1)

        if length(next_one) < 1 do
          # Can't calculate bonus yet
          total_score
        else
          frame_score = 10 + hd(next_one)
          score_frames(rolls, frame + 1, roll_index + 2, total_score + frame_score)
        end

      [first, second | _] ->
        # Regular frame
        frame_score = first + second
        score_frames(rolls, frame + 1, roll_index + 2, total_score + frame_score)

      _ ->
        # Not enough rolls to complete frame
        total_score
    end
  end
end
