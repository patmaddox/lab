# Example Elixir script

defmodule Config do
  def load do
    %{
      name: "example",
      enabled: true
    }
  end
end

IO.inspect(Config.load())
