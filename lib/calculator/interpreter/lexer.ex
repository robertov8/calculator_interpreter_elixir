defmodule Calculator.Interpreter.Lexer do
  alias Calculator.Interpreter.{Parser, Token}

  @numbers ~w(0 1 2 3 4 5 6 7 8 9 10)
  @arithmetic_operators ~w(+ - * /)

  def advance(%Parser{} = parser) do
    pos = parser.pos + 1

    if parser.pos > String.length(parser.text) - 1 do
      struct(parser, current_char: nil, pos: pos)
    else
      current_char = String.at(parser.text, pos)
      struct(parser, current_char: current_char, pos: pos)
    end
  end

  def skip_whitespace(%Parser{current_char: nil} = parser), do: parser

  def skip_whitespace(%Parser{current_char: " "} = parser) do
    parser
    |> advance()
    |> skip_whitespace()
  end

  def skip_whitespace(%Parser{} = parser), do: parser

  @doc """
  Lexical analyzer (also known as scanner or tokenizer)

  This method is responsible for breaking a sentence
  apart into tokens. One token at a time.
  """
  def get_next_token(%Parser{current_char: current_char} = parser) do
    do_get_next_token(current_char, parser)
  end

  defp do_get_next_token(nil, parser) do
    struct(parser, current_token: Token.new(:eof, nil))
  end

  defp do_get_next_token(" ", parser) do
    parser
    |> skip_whitespace()
    |> get_next_token()
  end

  defp do_get_next_token(current_char, parser) when current_char in @arithmetic_operators do
    {name, func} =
      case parser.current_char do
        "+" -> {:plus, &Kernel.+/2}
        "-" -> {:minus, &Kernel.-/2}
      end

    # "*" -> &Kernel.*/2
    # "/" -> &Kernel.//2

    token = Token.new(name, func)

    parser
    |> advance()
    |> struct(current_token: token)
  end

  defp do_get_next_token(current_char, parser) when current_char in @numbers do
    current_char = String.at(parser.text, parser.pos)
    next_char = String.at(parser.text, parser.pos + 1)

    acc = [current_char | parser.acc]

    if next_char in @numbers do
      parser
      |> advance()
      |> struct(acc: acc)
      |> get_next_token()
    else
      acc_char = acc |> Enum.reverse() |> Enum.join("")
      token = Token.new(:integer, String.to_integer(acc_char))

      parser
      |> advance()
      |> struct(current_token: token, acc: [])
    end
  end
end
