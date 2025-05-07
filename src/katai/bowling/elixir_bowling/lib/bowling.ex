defmodule Bowling do
  defstruct score: nil, frames: []

  def roll(game, pins) do
    new_frames = add_roll_to_frames(game.frames, pins)
    new_score = compute_score(new_frames)
    %{game | frames: new_frames, score: new_score}
  end

  defp compute_score(frames) do
    case frames do
      [] -> nil
      [[_]] -> nil
      [[10], [_a]] -> nil
      [[a, b]] when a + b == 10 -> nil
      frames -> compute_frames_score(frames)
    end
  end

  defp compute_frames_score([]), do: 0

  defp compute_frames_score(frames) do
    [frame | rest] = frames
    frame_score(frame, rest) + compute_frames_score(rest)
  end

  # tenth frame bonus has three rolls
  defp frame_score(frame, _rest) when length(frame) == 3 do
    Enum.sum(frame)
  end

  # tenth frame can start with a strike, not ready to count bonus yet
  defp frame_score([10, _], _rest), do: 0

  defp frame_score([10], rest) do
    compute_bonus(2, rest)
  end

  defp frame_score([a, b], rest) when a + b == 10 do
    compute_bonus(1, rest)
  end

  defp frame_score([a, b], _rest), do: a + b
  defp frame_score(_, _), do: 0

  defp compute_bonus(count, frames) do
    bonus_rolls =
      frames
      |> Enum.take(count)
      |> List.flatten()
      |> Enum.take(count)

    if length(bonus_rolls) == count do
      10 + Enum.sum(bonus_rolls)
    else
      0
    end
  end

  defp add_roll_to_frames(frames, pins) do
    if not final_frame?(frames) and complete_frame?(List.last(frames)) do
      frames ++ [[pins]]
    else
      List.update_at(frames, -1, &(&1 ++ [pins]))
    end
  end

  defp final_frame?(frames) do
    length(frames) == 10
  end

  defp complete_frame?(frame) do
    is_nil(frame) or length(frame) == 2 or frame == [10]
  end
end
