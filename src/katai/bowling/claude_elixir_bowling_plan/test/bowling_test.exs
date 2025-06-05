defmodule BowlingTest do
  use ExUnit.Case
  doctest Bowling

  test "creates a game struct" do
    game = %Bowling{}
    assert game.frames == []
    assert game.score == 0
    assert game.complete? == false
  end

  test "new_game creates a game with one empty frame" do
    game = Bowling.new_game()
    assert length(game.frames) == 1
    assert List.first(game.frames).rolls == []
  end

  test "roll adds pins to current frame" do
    game = Bowling.new_game()
    game = Bowling.roll(game, 3)

    frame = List.first(game.frames)
    assert frame.rolls == [3]
    assert frame.type == :open
  end

  test "roll creates new frame after strike" do
    game = Bowling.new_game()
    game = Bowling.roll(game, 10)

    assert length(game.frames) == 2
    assert List.first(game.frames).type == :strike
  end

  test "roll creates new frame after two rolls" do
    game =
      Bowling.new_game()
      |> Bowling.roll(3)
      |> Bowling.roll(4)

    assert length(game.frames) == 2
    assert List.first(game.frames).type == :open
    assert List.first(game.frames).rolls == [3, 4]
  end

  test "spare is detected correctly" do
    game =
      Bowling.new_game()
      |> Bowling.roll(6)
      |> Bowling.roll(4)

    assert List.first(game.frames).type == :spare
  end
end
