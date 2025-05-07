defmodule Bowling do
  defstruct score: nil, frames: []

  def roll(game, pins) do
    new_frames = add_roll_to_frames(game.frames, pins)
    %{game | frames: new_frames, score: compute_score(new_frames)}
  end

  defp compute_score([]), do: nil

  defp compute_score(frames) do
    complete = complete_frames_with_bonuses(frames)

    case complete do
      [] -> nil
      frames -> Enum.sum(Enum.map(frames, &frame_score/1))
    end
  end

  defp frame_score([roll1, roll2] = frame) do
    cond do
      is_spare_frame?(frame) -> 10
      true -> roll1 + roll2
    end
  end

  defp complete_frames_with_bonuses([frame | rest] = _frames) do
    cond do
      not is_complete_frame?(frame) -> []
      is_spare_frame?(frame) && rest == [] -> []
      is_spare_frame?(frame) && not Enum.empty?(rest) -> [frame]
      true -> [frame | complete_frames_with_bonuses(rest)]
    end
  end

  defp complete_frames_with_bonuses([]), do: []

  defp is_spare_frame?(frame) do
    length(frame) == 2 && Enum.sum(frame) == 10
  end

  defp is_complete_frame?(frame) do
    length(frame) == 2
  end

  defp add_roll_to_frames(frames, pins) do
    case frames do
      [] ->
        [[pins]]

      frames when is_list(frames) ->
        if is_complete_frame?(List.last(frames)) do
          frames ++ [[pins]]
        else
          List.update_at(frames, -1, &(&1 ++ [pins]))
        end
    end
  end
end
