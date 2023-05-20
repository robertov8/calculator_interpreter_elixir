defmodule Calculator do
  @moduledoc """
  Documentation for `Calculator`.
  """

  alias Calculator.Interpreter

  @doc """
  Hello world.

  ## Examples

      iex> Calculator.hello()
      :world

  """

  defdelegate eval(string), to: Calculator.Interpreter
end
