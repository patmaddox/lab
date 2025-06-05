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
    frame_number = length(game.frames)
    updated_frame = add_roll_to_frame(current_frame, pins, frame_number)

    frames = List.replace_at(game.frames, -1, updated_frame)
    frames = maybe_add_new_frame(frames, updated_frame)

    %{game | frames: frames}
  end

  defp add_roll_to_frame(%Frame{rolls: rolls} = frame, pins, frame_number) do
    new_rolls = rolls ++ [pins]
    frame_type = determine_frame_type(new_rolls, frame_number)
    %{frame | rolls: new_rolls, type: frame_type}
  end

  # Frame 10 special handling
  defp determine_frame_type(rolls, 10) do
    case rolls do
      [10] -> :strike
      [10, 10] -> :strike
      [10, 10, _] -> :strike
      [10, a, b] when a + b == 10 -> :spare
      [10, a, _] when a < 10 -> :open
      [a, b] when a + b == 10 -> :spare
      [a, b, _] when a + b == 10 -> :spare
      [a, b] when a + b < 10 -> :open
      _ -> :open
    end
  end

  # Regular frames 1-9
  defp determine_frame_type([10], _), do: :strike
  defp determine_frame_type([a, b], _) when a + b == 10, do: :spare
  defp determine_frame_type([a, b], _) when a + b < 10, do: :open
  defp determine_frame_type(_, _), do: :open

  defp maybe_add_new_frame(frames, %Frame{type: :strike}) when length(frames) < 10 do
    frames ++ [%Frame{}]
  end

  defp maybe_add_new_frame(frames, %Frame{rolls: [_, _]}) when length(frames) < 10 do
    frames ++ [%Frame{}]
  end

  defp maybe_add_new_frame(frames, _), do: frames

  @doc """
  Calculates the total score for the game.
  """
  def score(%Bowling{frames: frames}) do
    frames
    |> Enum.with_index()
    |> Enum.map(fn {frame, index} -> calculate_frame_score(frame, frames, index) end)
    |> Enum.sum()
  end

  # Frame 10 scoring
  defp calculate_frame_score(%Frame{rolls: rolls}, _frames, 9) do
    Enum.sum(rolls)
  end

  # Regular frame scoring
  defp calculate_frame_score(%Frame{type: :strike, rolls: [10]}, frames, index) do
    10 + strike_bonus(frames, index)
  end

  defp calculate_frame_score(%Frame{type: :spare, rolls: [a, b]}, frames, index)
       when a + b == 10 do
    10 + spare_bonus(frames, index)
  end

  defp calculate_frame_score(%Frame{rolls: rolls}, _frames, _index) do
    Enum.sum(rolls)
  end

  defp strike_bonus(frames, index) when index < 9 do
    next_frame = Enum.at(frames, index + 1)

    cond do
      # Strike in frame 9, bonus comes from frame 10
      index == 8 ->
        case next_frame do
          %Frame{rolls: [a, b | _]} -> a + (b || 0)
          %Frame{rolls: [a]} -> a
          _ -> 0
        end

      # Strike in frame 8, check if frame 9 is also a strike
      index == 7 ->
        case next_frame do
          %Frame{type: :strike, rolls: [10]} ->
            frame_10 = Enum.at(frames, 9)
            10 + List.first(frame_10.rolls || [0])

          %Frame{rolls: [a, b]} ->
            a + (b || 0)

          %Frame{rolls: [a]} ->
            a

          _ ->
            0
        end

      # Regular strike bonus for frames 1-7
      true ->
        case next_frame do
          %Frame{type: :strike, rolls: [10]} ->
            next_next_frame = Enum.at(frames, index + 2)
            10 + List.first(next_next_frame.rolls || [0])

          %Frame{rolls: [a, b]} ->
            a + (b || 0)

          %Frame{rolls: [a]} ->
            a

          _ ->
            0
        end
    end
  end

  defp strike_bonus(_frames, _index), do: 0

  defp spare_bonus(frames, index) when index < 9 do
    next_frame = Enum.at(frames, index + 1)

    case next_frame do
      %Frame{rolls: [a | _]} -> a
      _ -> 0
    end
  end

  defp spare_bonus(_frames, _index), do: 0
end
