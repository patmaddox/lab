defmodule Bowling do
  defstruct score: nil, frames: []

  def roll(game, pins) do
    new_frames = add_roll_to_frames(game.frames, pins)
    %{game | frames: new_frames, score: compute_score(new_frames)}
  end

  def is_complete_frame?(frame) do
    length(frame) == 2
  end

  defp compute_score(frames) do
    frames
    |> complete_frames()
    |> case do
      [] ->
        nil

      frames ->
        if is_spare_frame?(List.last(frames)) do
          nil
        else
          Enum.reduce(frames, 0, fn frame, score ->
            score + Enum.sum(frame)
          end)
        end
    end
  end

  defp is_spare_frame?(frame) do
    length(frame) == 2 && Enum.sum(frame) == 10
  end

  defp complete_frames(frames) do
    Enum.filter(frames, &is_complete_frame?/1)
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
