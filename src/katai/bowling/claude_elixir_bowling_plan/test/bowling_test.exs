defmodule BowlingTest do
  use ExUnit.Case
  doctest Bowling

  test "creates a game struct" do
    game = %Bowling{}
    assert game.frames == []
    assert game.score == 0
    assert game.complete? == false
  end
end
