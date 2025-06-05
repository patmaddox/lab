defmodule Bowling do
  @moduledoc """
  A bowling game scoring system.
  """

  defstruct frames: [], score: 0, complete?: false

  defmodule Frame do
    @moduledoc """
    Represents a single frame in a bowling game.
    """

    defstruct rolls: [], score: 0, type: :open
  end

  @doc """
  Creates a new bowling game.
  """
  def new_game do
    %Bowling{frames: [%Frame{}]}
  end

  @doc """
  Records a roll in the current game.
  """
  def roll(%Bowling{} = game, pins) when pins >= 0 and pins <= 10 do
    current_frame = List.last(game.frames)
    updated_frame = add_roll_to_frame(current_frame, pins)

    frames = List.replace_at(game.frames, -1, updated_frame)
    frames = maybe_add_new_frame(frames, updated_frame)

    %{game | frames: frames}
  end

  defp add_roll_to_frame(%Frame{rolls: rolls} = frame, pins) do
    new_rolls = rolls ++ [pins]
    frame_type = determine_frame_type(new_rolls)
    %{frame | rolls: new_rolls, type: frame_type}
  end

  defp determine_frame_type([10]), do: :strike
  defp determine_frame_type([a, b]) when a + b == 10, do: :spare
  defp determine_frame_type([a, b]) when a + b < 10, do: :open
  defp determine_frame_type(_), do: :open

  defp maybe_add_new_frame(frames, %Frame{type: :strike}) when length(frames) < 10 do
    frames ++ [%Frame{}]
  end

  defp maybe_add_new_frame(frames, %Frame{rolls: [_, _]}) when length(frames) < 10 do
    frames ++ [%Frame{}]
  end

  defp maybe_add_new_frame(frames, _), do: frames
end
