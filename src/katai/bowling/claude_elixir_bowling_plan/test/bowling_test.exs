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

    test "incomplete strike does not get scored" do
      game =
        Bowling.new_game()
        |> Bowling.roll(10)
        |> Bowling.roll(3)

      assert Bowling.score(game) == 3
    end

    test "incomplete spare does not get scored" do
      game =
        Bowling.new_game()
        |> Bowling.roll(6)
        |> Bowling.roll(4)

      assert Bowling.score(game) == 0
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

  describe "comprehensive test scenarios" do
    test "gutter game scores 0" do
      game = Bowling.new_game()

      # Roll 20 zeros (all gutter balls)
      game = Enum.reduce(1..20, game, fn _, acc -> Bowling.roll(acc, 0) end)

      assert Bowling.score(game) == 0
    end

    test "all spares with 5 pins each time" do
      game = Bowling.new_game()

      # Roll 21 times: 5 pins each roll (10 spares + 1 bonus)
      game = Enum.reduce(1..21, game, fn _, acc -> Bowling.roll(acc, 5) end)

      # Each spare scores 10 + 5 = 15, total = 150
      assert Bowling.score(game) == 150
    end

    test "alternating strikes and gutter balls" do
      game = Bowling.new_game()

      # Frames 1,3,5,7,9: strikes
      # Frames 2,4,6,8,10: gutter balls
      game =
        game
        |> Bowling.roll(10)
        # Strike, bonus: 0+0=0, score: 10
        |> Bowling.roll(0)
        |> Bowling.roll(0)
        # Open, score: 0
        |> Bowling.roll(10)
        # Strike, bonus: 0+0=0, score: 10
        |> Bowling.roll(0)
        |> Bowling.roll(0)
        # Open, score: 0
        |> Bowling.roll(10)
        # Strike, bonus: 0+0=0, score: 10
        |> Bowling.roll(0)
        |> Bowling.roll(0)
        # Open, score: 0
        |> Bowling.roll(10)
        # Strike, bonus: 0+0=0, score: 10
        |> Bowling.roll(0)
        |> Bowling.roll(0)
        # Open, score: 0
        |> Bowling.roll(10)
        # Strike, bonus: 0+0=0, score: 10
        |> Bowling.roll(0)
        |> Bowling.roll(0)

      # Frame 10: open frame, score: 0
      assert Bowling.score(game) == 50
    end

    test "consecutive strikes (turkey)" do
      game = Bowling.new_game()

      # Three consecutive strikes, then open frames
      game =
        game
        |> Bowling.roll(10)
        # Strike 1, bonus: 10+10=20, score: 30
        |> Bowling.roll(10)
        # Strike 2, bonus: 10+3=13, score: 23
        |> Bowling.roll(10)
        # Strike 3, bonus: 3+4=7, score: 17
        |> Bowling.roll(3)
        |> Bowling.roll(4)

      # Total so far: 30 + 23 + 17 + 7 = 77
      assert Bowling.score(game) == 77
    end

    test "spare followed by strike" do
      game = Bowling.new_game()

      game =
        game
        |> Bowling.roll(7)
        |> Bowling.roll(3)
        # Spare, bonus: 10, score: 20
        |> Bowling.roll(10)
        # Strike, bonus: 4+3=7, score: 17
        |> Bowling.roll(4)
        |> Bowling.roll(3)

      # Total: 20 + 17 + 7 = 44
      assert Bowling.score(game) == 44
    end

    test "all open frames with different scores" do
      game = Bowling.new_game()

      rolls = [1, 2, 2, 3, 3, 4, 4, 1, 1, 5, 0, 8, 2, 7, 3, 3, 1, 8, 2, 6]
      game = Enum.reduce(rolls, game, fn pins, acc -> Bowling.roll(acc, pins) end)

      expected_score = Enum.sum(rolls)
      assert Bowling.score(game) == expected_score
      assert length(game.frames) == 10
    end

    test "strike in frame 8 followed by strikes in frame 9 and 10" do
      game = Bowling.new_game()

      # Roll 7 open frames (score: 14 each)
      game =
        Enum.reduce(1..7, game, fn _, acc ->
          acc |> Bowling.roll(1) |> Bowling.roll(1)
        end)

      # Frame 8: strike (bonus from two strikes = 20)
      game = Bowling.roll(game, 10)
      # Frame 9: strike (bonus from frame 10 first two rolls)
      game = Bowling.roll(game, 10)
      # Frame 10: strike, strike, strike
      game = game |> Bowling.roll(10) |> Bowling.roll(10) |> Bowling.roll(10)

      # Frame 1-7: 2 each = 14
      # Frame 8: 10 + 10 + 10 = 30 (strike bonus from frames 9,10)
      # Frame 9: 10 + 10 + 10 = 30 (strike bonus from frame 10)
      # Frame 10: 30 (strike + strike + strike)
      # Total: 14 + 30 + 30 + 30 = 104
      assert Bowling.score(game) == 104
    end
  end

  describe "game completion detection" do
    test "game is complete after 10 open frames" do
      game = Bowling.new_game()

      # Roll 20 times (10 open frames)
      game = Enum.reduce(1..20, game, fn _, acc -> Bowling.roll(acc, 1) end)

      assert length(game.frames) == 10
    end

    test "game is complete after 9 strikes plus frame 10" do
      game = Bowling.new_game()

      # 9 strikes + frame 10 (3 rolls)
      game = Enum.reduce(1..12, game, fn _, acc -> Bowling.roll(acc, 10) end)

      assert length(game.frames) == 10
    end

    test "game handles mixed strikes and spares correctly" do
      game = Bowling.new_game()

      # Complex game with various scenarios
      game =
        game
        |> Bowling.roll(10)
        # Frame 1: Strike
        |> Bowling.roll(7)
        |> Bowling.roll(3)
        # Frame 2: Spare
        |> Bowling.roll(9)
        |> Bowling.roll(0)
        # Frame 3: Open
        |> Bowling.roll(10)
        # Frame 4: Strike
        |> Bowling.roll(0)
        |> Bowling.roll(8)
        # Frame 5: Open
        |> Bowling.roll(8)
        |> Bowling.roll(2)
        # Frame 6: Spare
        |> Bowling.roll(0)
        |> Bowling.roll(6)
        # Frame 7: Open
        |> Bowling.roll(10)
        # Frame 8: Strike
        |> Bowling.roll(10)
        # Frame 9: Strike
        |> Bowling.roll(10)
        |> Bowling.roll(8)
        |> Bowling.roll(1)

      # Frame 10: Strike + 8 + 1
      assert length(game.frames) == 10

      # Manual calculation:
      # Frame 1: 10 + 7 + 3 = 20
      # Frame 2: 10 + 9 = 19
      # Frame 3: 9
      # Frame 4: 10 + 0 + 8 = 18
      # Frame 5: 8
      # Frame 6: 10 + 0 = 10
      # Frame 7: 6
      # Frame 8: 10 + 10 + 10 = 30
      # Frame 9: 10 + 10 + 8 = 28
      # Frame 10: 19
      # Total: 167
      assert Bowling.score(game) == 167
    end
  end
end
