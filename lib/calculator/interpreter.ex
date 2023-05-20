defmodule Calculator.Interpreter do
  alias Calculator.Interpreter.Parser

  def eval(text) do
    text
    |> Parser.new()
    |> Parser.expr()
  end
end
