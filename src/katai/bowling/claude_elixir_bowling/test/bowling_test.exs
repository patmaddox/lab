defmodule BowlingTest do
  use ExUnit.Case
  doctest Bowling

  describe "scoring a game of bowling" do
    test "Regular Frame (No Strike/Spare)" do
      game =
        [1, 2]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      assert game.score == 3
    end

    test "Frame with Miss" do
      game =
        [3, 0]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      assert game.score == 3
    end

    test "Strike" do
      game =
        [10, 3, 4]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      assert game.score == 24
    end

    test "Strike (Incomplete - Only One Ball Rolled After)" do
      game =
        [10, 5]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      assert game.score == 0
    end

    test "Strike in Second Frame (Incomplete)" do
      game =
        [3, 4, 10, 6]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      assert game.score == 7
    end

    test "Spare" do
      game =
        [7, 3, 5, 2]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      assert game.score == 22
    end

    test "10th Frame - Strike with Bonus Rolls" do
      game =
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 5, 3]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      assert game.score == 36
    end

    test "10th Frame - Spare with Bonus Roll" do
      game =
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 7, 3, 5]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      assert game.score == 33
    end

    test "Perfect Game" do
      game =
        [10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      assert game.score == 300
    end

    test "Consecutive Strikes" do
      game =
        [10, 10, 3, 4]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      assert game.score == 47
    end

    test "Spare followed by Strike" do
      game =
        [7, 3, 10, 5, 2]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      assert game.score == 44
    end

    test "Strike followed by Spare" do
      game =
        [10, 7, 3, 5, 2]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      assert game.score == 42
    end

    test "Multiple Spares" do
      game =
        [7, 3, 6, 4, 5, 2]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      assert game.score == 38
    end

    test "Incomplete Spare" do
      game =
        [7, 3, 5]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      assert game.score == 15
    end

    test "Realistic Mixed Game" do
      game =
        [6, 4, 7, 2, 10, 5, 3, 8, 1, 4, 6, 2, 0, 10, 10, 9, 1, 8]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      assert game.score == 142
    end

    test "10th Frame - Strike but incomplete (missing both bonus rolls)" do
      game =
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      # Should be just the first 9 frames
      assert game.score == 18
    end

    test "10th Frame - Strike with only one bonus roll" do
      game =
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 5]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      # Should be just the first 9 frames until complete
      assert game.score == 18
    end

    test "10th Frame - Spare but incomplete (missing bonus roll)" do
      game =
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 7, 3]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      # Should be just the first 9 frames
      assert game.score == 18
    end
  end
end
