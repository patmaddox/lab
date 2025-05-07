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
      frames -> compute_frames_score(frames)
    end
  end

  defp compute_frames_score(frames) do
    case frames do
      [frame] when length(frame) == 2 ->
        frame_score(frame, nil)

      [frame, next | _rest] ->
        frame_score(frame, next) + compute_frames_score(tl(frames))

      [_incomplete | _] ->
        0
    end
  end

  defp frame_score(frame, next_frame) do
    case frame do
      [roll1, roll2] when roll1 + roll2 == 10 ->
        case next_frame do
          nil -> nil
          [next_roll | _] -> 10 + next_roll
        end

      [roll1, roll2] ->
        roll1 + roll2
    end
  end

  defp add_roll_to_frames(frames, pins) do
    case frames do
      [] ->
        [[pins]]

      frames when is_list(frames) ->
        last = List.last(frames)

        if length(last) == 2 do
          frames ++ [[pins]]
        else
          List.update_at(frames, -1, &(&1 ++ [pins]))
        end
    end
  end
end
