defmodule Calculator.Interpreter.Lexer do
  alias Calculator.{Interpreter, Token}

  @numbers ~w(0 1 2 3 4 5 6 7 8 9 10)
  @arithmetic_operators ~w(+ - * /)

  def advance(%Interpreter{} = interpreter) do
    pos = interpreter.pos + 1

    if interpreter.pos > String.length(interpreter.text) - 1 do
      struct(interpreter, current_char: nil, pos: pos)
    else
      current_char = String.at(interpreter.text, pos)
      struct(interpreter, current_char: current_char, pos: pos)
    end
  end

  def skip_whitespace(%Interpreter{current_char: nil} = interpreter), do: interpreter

  def skip_whitespace(%Interpreter{current_char: " "} = interpreter) do
    interpreter
    |> advance()
    |> skip_whitespace()
  end

  def skip_whitespace(%Interpreter{} = interpreter), do: interpreter

  @doc """
  Lexical analyzer (also known as scanner or tokenizer)

  This method is responsible for breaking a sentence
  apart into tokens. One token at a time.
  """
  def get_next_token(%Interpreter{current_char: current_char} = interpreter) do
    do_get_next_token(current_char, interpreter)
  end

  defp do_get_next_token(nil, interpreter) do
    struct(interpreter, current_token: Token.new(:eof, nil))
  end

  defp do_get_next_token(" ", interpreter) do
    interpreter
    |> skip_whitespace()
    |> get_next_token()
  end

  defp do_get_next_token(current_char, interpreter) when current_char in @arithmetic_operators do
    operator =
      case interpreter.current_char do
        "+" -> &Kernel.+/2
        "-" -> &Kernel.-/2
        "*" -> &Kernel.*/2
        "/" -> &Kernel.//2
      end

    token = Token.new(:plus, operator)

    interpreter
    |> advance()
    |> struct(current_token: token)
  end

  defp do_get_next_token(current_char, interpreter) when current_char in @numbers do
    current_char = String.at(interpreter.text, interpreter.pos)
    next_char = String.at(interpreter.text, interpreter.pos + 1)

    acc = [current_char | interpreter.acc]

    if next_char in @numbers do
      interpreter
      |> advance()
      |> struct(acc: acc)
      |> get_next_token()
    else
      acc_char = acc |> Enum.reverse() |> Enum.join("")
      token = Token.new(:integer, String.to_integer(acc_char))

      interpreter
      |> advance()
      |> struct(current_token: token, acc: [])
    end
  end
end
