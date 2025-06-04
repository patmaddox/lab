defmodule BowlingTest do
  use ExUnit.Case
  doctest Bowling

  describe "scoring a game of bowling" do
    test "Regular Frame (No Strike/Spare)" do
      game =
        %Bowling{}
        |> Bowling.roll(1)
        |> Bowling.roll(2)

      assert game.score == 3
    end

    @tag :skip
    test "Frame with Miss" do
      game =
        %Bowling{}
        |> Bowling.roll(3)
        |> Bowling.roll(0)

      assert game.score == 3
    end

    @tag :skip
    test "Strike" do
      game =
        %Bowling{}
        |> Bowling.roll(10)
        |> Bowling.roll(3)
        |> Bowling.roll(4)

      assert game.score == 24
    end

    @tag :skip
    test "Strike (Incomplete - Only One Ball Rolled After)" do
      game =
        %Bowling{}
        |> Bowling.roll(10)
        |> Bowling.roll(5)

      assert game.score == 0
    end

    @tag :skip
    test "Strike in Second Frame (Incomplete)" do
      game =
        %Bowling{}
        |> Bowling.roll(3)
        |> Bowling.roll(4)
        |> Bowling.roll(10)
        |> Bowling.roll(6)

      assert game.score == 7
    end

    @tag :skip
    test "Spare" do
      game =
        %Bowling{}
        |> Bowling.roll(7)
        |> Bowling.roll(3)
        |> Bowling.roll(5)
        |> Bowling.roll(2)

      assert game.score == 22
    end

    @tag :skip
    test "10th Frame - Strike with Bonus Rolls" do
      game =
        %Bowling{}
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(10)
        |> Bowling.roll(5)
        |> Bowling.roll(3)

      assert game.score == 36
    end

    @tag :skip
    test "10th Frame - Spare with Bonus Roll" do
      game =
        %Bowling{}
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(1)
        |> Bowling.roll(7)
        |> Bowling.roll(3)
        |> Bowling.roll(5)

      assert game.score == 33
    end

    @tag :skip
    test "Perfect Game" do
      game =
        %Bowling{}
        |> Bowling.roll(10)
        |> Bowling.roll(10)
        |> Bowling.roll(10)
        |> Bowling.roll(10)
        |> Bowling.roll(10)
        |> Bowling.roll(10)
        |> Bowling.roll(10)
        |> Bowling.roll(10)
        |> Bowling.roll(10)
        |> Bowling.roll(10)
        |> Bowling.roll(10)
        |> Bowling.roll(10)

      assert game.score == 300
    end
  end
end
