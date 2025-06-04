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

    @tag :skip
    test "10th Frame - Strike with Bonus Rolls" do
      game =
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 5, 3]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      assert game.score == 36
    end

    @tag :skip
    test "10th Frame - Spare with Bonus Roll" do
      game =
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 7, 3, 5]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      assert game.score == 33
    end

    @tag :skip
    test "Perfect Game" do
      game =
        [10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10]
        |> Enum.reduce(%Bowling{}, &Bowling.roll(&2, &1))

      assert game.score == 300
    end
  end
end
