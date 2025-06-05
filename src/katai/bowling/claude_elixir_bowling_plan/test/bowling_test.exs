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

  describe "frame 10 special rules" do
    test "allows 3 rolls in frame 10 with strike" do
      game = Bowling.new_game()

      # Roll 9 strikes
      game = Enum.reduce(1..9, game, fn _, acc -> Bowling.roll(acc, 10) end)

      # Frame 10: strike, then two more rolls
      game =
        game
        # Strike in frame 10
        |> Bowling.roll(10)
        # Bonus roll 1
        |> Bowling.roll(5)
        # Bonus roll 2
        |> Bowling.roll(3)

      frame_10 = List.last(game.frames)
      assert frame_10.rolls == [10, 5, 3]
      assert frame_10.type == :open
    end

    test "allows 3 rolls in frame 10 with spare" do
      game = Bowling.new_game()

      # Roll 9 open frames
      game =
        Enum.reduce(1..9, game, fn _, acc ->
          acc |> Bowling.roll(1) |> Bowling.roll(1)
        end)

      # Frame 10: spare, then one more roll
      game =
        game
        # First roll
        |> Bowling.roll(6)
        # Spare
        |> Bowling.roll(4)
        # Bonus roll
        |> Bowling.roll(7)

      frame_10 = List.last(game.frames)
      assert frame_10.rolls == [6, 4, 7]
      assert frame_10.type == :spare
    end

    test "only allows 2 rolls in frame 10 with open frame" do
      game = Bowling.new_game()

      # Roll 9 open frames
      game =
        Enum.reduce(1..9, game, fn _, acc ->
          acc |> Bowling.roll(1) |> Bowling.roll(1)
        end)

      # Frame 10: open frame (no bonus roll)
      game =
        game
        |> Bowling.roll(3)
        |> Bowling.roll(4)

      frame_10 = List.last(game.frames)
      assert frame_10.rolls == [3, 4]
      assert frame_10.type == :open
      assert length(game.frames) == 10
    end

    test "perfect game scores 300" do
      game = Bowling.new_game()

      # Roll 12 strikes (9 regular + 3 in frame 10)
      game = Enum.reduce(1..12, game, fn _, acc -> Bowling.roll(acc, 10) end)

      assert Bowling.score(game) == 300
    end

    test "spare in frame 9 gets bonus from frame 10" do
      game = Bowling.new_game()

      # Roll 8 open frames
      game =
        Enum.reduce(1..8, game, fn _, acc ->
          acc |> Bowling.roll(1) |> Bowling.roll(1)
        end)

      # Frame 9: spare
      game =
        game
        |> Bowling.roll(5)
        |> Bowling.roll(5)

      # Frame 10: starts with 7
      game =
        game
        |> Bowling.roll(7)
        |> Bowling.roll(2)

      # Frame 9 should score 10 + 7 = 17
      # Total should be 8 * 2 + 17 + 9 = 42
      assert Bowling.score(game) == 42
    end
  end
end
