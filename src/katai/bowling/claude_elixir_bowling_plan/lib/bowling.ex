defmodule Bowling do
  @moduledoc """
  A bowling game scoring system.
  """

  defstruct frames: [], score: 0, complete?: false

  defmodule Frame do
    @moduledoc """
    Represents a single frame in a bowling game.
    """

    defstruct rolls: [], score: 0, type: :open
  end
end
