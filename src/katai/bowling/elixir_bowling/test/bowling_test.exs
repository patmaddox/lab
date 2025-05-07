defmodule BowlingTest do
  use ExUnit.Case
  doctest Bowling

  test "new game has no score or frames" do
    game = %Bowling{}

    assert game.frames == []
    assert game.score == nil
  end

  test "one incomplete frame" do
    game =
      %Bowling{}
      |> Bowling.roll(1)

    assert game.frames == [[1]]
    assert game.score == nil
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

    assert game.frames == [[1, 2], [3]]
    assert game.score == 3
  end

  test "frame with one miss" do
    game =
      %Bowling{}
      |> Bowling.roll(0)
      |> Bowling.roll(1)

    assert game.frames == [[0, 1]]
    assert game.score == 1
  end

  test "frame with two misses" do
    game =
      %Bowling{}
      |> Bowling.roll(0)
      |> Bowling.roll(0)

    assert game.frames == [[0, 0]]
    assert game.score == 0
  end

  test "two complete frames" do
    game =
      %Bowling{}
      |> Bowling.roll(1)
      |> Bowling.roll(2)
      |> Bowling.roll(3)
      |> Bowling.roll(4)

    assert game.frames == [[1, 2], [3, 4]]
    assert game.score == 10
  end

  test "incomplete spare frame" do
    game =
      %Bowling{}
      |> Bowling.roll(9)
      |> Bowling.roll(1)

    assert game.frames == [[9, 1]]
    assert game.score == nil
  end

  test "complete spare frame" do
    game =
      %Bowling{}
      |> Bowling.roll(9)
      |> Bowling.roll(1)
      |> Bowling.roll(3)

    assert game.frames == [[9, 1], [3]]
    assert game.score == 13
  end

  test "complete spare frame followed by complete frame" do
    game =
      %Bowling{}
      |> Bowling.roll(9)
      |> Bowling.roll(1)
      |> Bowling.roll(3)
      |> Bowling.roll(4)

    assert game.frames == [[9, 1], [3, 4]]
    assert game.score == 20
  end
end
