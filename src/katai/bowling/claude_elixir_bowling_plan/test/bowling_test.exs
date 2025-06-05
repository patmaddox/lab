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

  describe "roll/2" do
    test "adds pins to current frame" do
      game = Bowling.new_game()
      game = Bowling.roll(game, 3)

      frame = List.first(game.frames)
      assert frame.rolls == [3]
      assert frame.type == :open
    end

    test "creates new frame after strike" do
      game = Bowling.new_game()
      game = Bowling.roll(game, 10)

      assert length(game.frames) == 2
      assert List.first(game.frames).type == :strike
    end

    test "creates new frame after two rolls" do
      game =
        Bowling.new_game()
        |> Bowling.roll(3)
        |> Bowling.roll(4)

      assert length(game.frames) == 2
      assert List.first(game.frames).type == :open
      assert List.first(game.frames).rolls == [3, 4]
    end

    test "detects spare correctly" do
      game =
        Bowling.new_game()
        |> Bowling.roll(6)
        |> Bowling.roll(4)

      assert List.first(game.frames).type == :spare
    end
  end

  describe "score/1" do
    test "calculates basic open frame" do
      game =
        Bowling.new_game()
        |> Bowling.roll(3)
        |> Bowling.roll(4)

      assert Bowling.score(game) == 7
    end

    test "calculates strike with bonus" do
      game =
        Bowling.new_game()
        |> Bowling.roll(10)
        |> Bowling.roll(3)
        |> Bowling.roll(4)

      assert Bowling.score(game) == 24
    end

    test "calculates spare with bonus" do
      game =
        Bowling.new_game()
        |> Bowling.roll(6)
        |> Bowling.roll(4)
        |> Bowling.roll(3)
        |> Bowling.roll(2)

      assert Bowling.score(game) == 18
    end

    test "handles multiple frames" do
      game =
        Bowling.new_game()
        |> Bowling.roll(1)
        |> Bowling.roll(2)
        |> Bowling.roll(3)
        |> Bowling.roll(4)
        |> Bowling.roll(5)
        |> Bowling.roll(1)

      assert Bowling.score(game) == 16
    end
  end
end
