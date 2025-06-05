defmodule Bowling do
  @moduledoc """
  A bowling game scoring system.
  """

  @max_pins 10
  @min_pins 0
  @total_frames 10
  @last_regular_frame_index 9
  @frame_8_index 7
  @frame_9_index 8

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
  def roll(%Bowling{} = game, pins) when pins >= @min_pins and pins <= @max_pins do
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
  defp determine_frame_type(rolls, @total_frames) do
    case rolls do
      [@max_pins] -> :strike
      [@max_pins, @max_pins] -> :strike
      [@max_pins, @max_pins, _] -> :strike
      [@max_pins, a, b] when a + b == @max_pins -> :spare
      [@max_pins, a, _] when a < @max_pins -> :open
      [a, b] when a + b == @max_pins -> :spare
      [a, b, _] when a + b == @max_pins -> :spare
      [a, b] when a + b < @max_pins -> :open
      _ -> :open
    end
  end

  # Regular frames 1-9
  defp determine_frame_type([@max_pins], _), do: :strike
  defp determine_frame_type([a, b], _) when a + b == @max_pins, do: :spare
  defp determine_frame_type([a, b], _) when a + b < @max_pins, do: :open
  defp determine_frame_type(_, _), do: :open

  defp maybe_add_new_frame(frames, %Frame{type: :strike}) when length(frames) < @total_frames do
    frames ++ [%Frame{}]
  end

  defp maybe_add_new_frame(frames, %Frame{rolls: [_, _]}) when length(frames) < @total_frames do
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
  defp calculate_frame_score(%Frame{rolls: rolls}, _frames, @last_regular_frame_index) do
    Enum.sum(rolls)
  end

  # Regular frame scoring
  defp calculate_frame_score(%Frame{type: :strike, rolls: [@max_pins]}, frames, index) do
    bonus = strike_bonus(frames, index)
    if bonus == :incomplete, do: 0, else: @max_pins + bonus
  end

  defp calculate_frame_score(%Frame{type: :spare, rolls: [a, b]}, frames, index)
       when a + b == @max_pins do
    bonus = spare_bonus(frames, index)
    if bonus == :incomplete, do: 0, else: @max_pins + bonus
  end

  defp calculate_frame_score(%Frame{rolls: rolls}, _frames, _index) do
    Enum.sum(rolls)
  end

  defp strike_bonus(frames, index) when index < @last_regular_frame_index do
    next_frame = Enum.at(frames, index + 1)

    cond do
      # Strike in frame 9, bonus comes from frame 10
      index == @frame_9_index ->
        case next_frame do
          %Frame{rolls: [a, b | _]} -> a + b
          %Frame{rolls: [_a]} -> :incomplete
          _ -> :incomplete
        end

      # Strike in frame 8, check if frame 9 is also a strike
      index == @frame_8_index ->
        case next_frame do
          %Frame{type: :strike, rolls: [@max_pins]} ->
            frame_10 = Enum.at(frames, @last_regular_frame_index)

            case frame_10 do
              %Frame{rolls: [first_roll | _]} -> @max_pins + first_roll
              _ -> :incomplete
            end

          %Frame{rolls: [a, b]} ->
            a + b

          %Frame{rolls: [_a]} ->
            :incomplete

          _ ->
            :incomplete
        end

      # Regular strike bonus for frames 1-7
      true ->
        case next_frame do
          %Frame{type: :strike, rolls: [@max_pins]} ->
            next_next_frame = Enum.at(frames, index + 2)

            case next_next_frame do
              %Frame{rolls: [first_roll | _]} -> @max_pins + first_roll
              _ -> :incomplete
            end

          %Frame{rolls: [a, b]} ->
            a + b

          %Frame{rolls: [_a]} ->
            :incomplete

          _ ->
            :incomplete
        end
    end
  end

  defp strike_bonus(_frames, _index), do: 0

  defp spare_bonus(frames, index) when index < @last_regular_frame_index do
    next_frame = Enum.at(frames, index + 1)

    case next_frame do
      %Frame{type: :strike, rolls: [a]} -> a
      %Frame{rolls: [a, _b]} -> a
      # Frame 10 with 3 rolls
      %Frame{rolls: [a, _b, _c]} when index == @frame_9_index -> a
      _ -> :incomplete
    end
  end

  defp spare_bonus(_frames, _index), do: 0
end
