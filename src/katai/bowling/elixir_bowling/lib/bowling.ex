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
      [[a, b]] when a + b == 10 -> nil
      frames -> compute_frames_score(frames)
    end
  end

  defp compute_frames_score(frames) do
    case frames do
      [frame | rest] ->
        frame_score(frame) + bonus(frame, rest) + compute_frames_score(rest)

      _ ->
        0
    end
  end

  defp frame_score([a, b]), do: a + b
  defp frame_score(_), do: 0

  def bonus(frame, rest) do
    case frame do
      [a, b] when a + b == 10 ->
        case rest do
          [] -> 0
          [next_frame | _] -> hd(next_frame)
        end

      _ ->
        0
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
