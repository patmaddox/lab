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

  test "second frame is incomplete spare" do
    game =
      %Bowling{}
      |> Bowling.roll(3)
      |> Bowling.roll(4)
      |> Bowling.roll(9)
      |> Bowling.roll(1)

    assert game.frames == [[3, 4], [9, 1]]
    assert game.score == 7
  end

  test "incomplete strike frame" do
    game =
      %Bowling{}
      |> Bowling.roll(10)

    assert game.frames == [[10]]
    assert game.score == nil
  end

  test "incomplete strike frame, followed by one roll" do
    game =
      %Bowling{}
      |> Bowling.roll(10)
      |> Bowling.roll(2)

    assert game.frames == [[10], [2]]
    assert game.score == nil
  end

  test "incomplete strike frame, followed by another strike" do
    game =
      %Bowling{}
      |> Bowling.roll(10)
      |> Bowling.roll(10)

    assert game.frames == [[10], [10]]
    assert game.score == nil
  end

  test "complete strike frame" do
    game =
      %Bowling{}
      |> Bowling.roll(10)
      |> Bowling.roll(1)
      |> Bowling.roll(2)

    assert game.frames == [[10], [1, 2]]
    assert game.score == 16
  end

  test "cumulative strikes with open frame" do
    game =
      %Bowling{}
      |> Bowling.roll(10)
      |> Bowling.roll(10)
      |> Bowling.roll(10)

    assert game.frames == [[10], [10], [10]]
    assert game.score == 30
  end

  test "perfect game" do
    game =
      List.duplicate(10, 12)
      |> Enum.reduce(%Bowling{}, fn i, game ->
        Bowling.roll(game, i)
      end)

    assert game.frames == [[10], [10], [10], [10], [10], [10], [10], [10], [10], [10, 10, 10]]
    assert game.score == 300
  end

  test "strikes through final frame" do
    game =
      List.duplicate(10, 10)
      |> Enum.reduce(%Bowling{}, fn i, game ->
        Bowling.roll(game, i)
      end)

    assert game.frames == [[10], [10], [10], [10], [10], [10], [10], [10], [10], [10]]
    assert game.score == 240
  end

  test "strikes through final frame, one ball left" do
    game =
      List.duplicate(10, 11)
      |> Enum.reduce(%Bowling{}, fn i, game ->
        Bowling.roll(game, i)
      end)

    assert game.frames == [[10], [10], [10], [10], [10], [10], [10], [10], [10], [10, 10]]
    assert game.score == 270
  end

  test "spare on final frame" do
    game =
      (List.duplicate(10, 9) ++ [9, 1, 5])
      |> Enum.reduce(%Bowling{}, fn i, game ->
        Bowling.roll(game, i)
      end)

    assert game.frames == [[10], [10], [10], [10], [10], [10], [10], [10], [10], [9, 1, 5]]
    assert game.score == 274
  end

  test "spare on final frame, one ball left" do
    game =
      (List.duplicate(10, 9) ++ [9, 1])
      |> Enum.reduce(%Bowling{}, fn i, game ->
        Bowling.roll(game, i)
      end)

    assert game.frames == [[10], [10], [10], [10], [10], [10], [10], [10], [10], [9, 1]]
    assert game.score == 259
  end
end
