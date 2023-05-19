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
  def eval(text) do
    text
    |> Interpreter.new()
    |> Interpreter.exp()
  end
end
