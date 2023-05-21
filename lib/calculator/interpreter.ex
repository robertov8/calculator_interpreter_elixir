defmodule Calculator.Interpreter do
  alias Calculator.Interpreter.Parser

  def eval(text) do
    {:ok, pid} = Parser.start_link(text)

    Parser.expr(pid)
  end
end
