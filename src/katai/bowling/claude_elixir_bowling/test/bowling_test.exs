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
  end
end
