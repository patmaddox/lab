defmodule Example do
  @moduledoc """
  Example Elixir module.
  """

  def hello(name) do
    "Hello, #{name}!"
  end

  def factorial(0), do: 1

  def factorial(n) when n > 0 do
    n * factorial(n - 1)
  end

  def process_list(items) do
    items
    |> Enum.map(&String.upcase/1)
    |> Enum.filter(&(String.length(&1) > 3))
  end
end
