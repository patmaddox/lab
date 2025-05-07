defmodule BowlingTest do
  use ExUnit.Case
  doctest Bowling

  test "new game has no score or frames" do
    game = %Bowling{}

    assert is_nil(game.score)
    assert game.frames == []
  end

  test "one incomplete frame" do
    game =
      %Bowling{}
      |> Bowling.roll(1)

    assert game.frames == [[1]]
    assert is_nil(game.score)
  end

  test "one complete frame" do
    game =
      %Bowling{}
      |> Bowling.roll(1)
      |> Bowling.roll(2)

    assert game.frames == [[1, 2]]
    assert game.score == 3
  end

  test "two frames, with one incomplete" do
    game =
      %Bowling{}
      |> Bowling.roll(1)
      |> Bowling.roll(2)
      |> Bowling.roll(3)

    assert game.score == 3
    assert game.frames == [[1, 2], [3]]
  end
end
