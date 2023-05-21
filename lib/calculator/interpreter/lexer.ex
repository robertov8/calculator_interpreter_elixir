defmodule Calculator.Interpreter.Lexer do
  use GenServer

  alias Calculator.Interpreter.{Parser, Token}

  @numbers ~w(0 1 2 3 4 5 6 7 8 9 10)
  @arithmetic_operators ~w(+ - * /)

  # Client
  def start_link(%Parser{} = parser) do
    GenServer.start_link(__MODULE__, parser)
  end

  def get_next_token(pid) do
    GenServer.call(pid, :get_next_token)
  end

  # Callbacks

  @impl true
  def init(parser) do
    {:ok, parser}
  end

  @impl true
  def handle_call(:get_next_token, _from, %Parser{} = parser) do
    parser = handle_get_next_token(parser)

    {:reply, parser, parser}
  end

  # Lexical analyzer (also known as scanner or tokenizer)
  #
  # This method is responsible for breaking a sentence
  # apart into tokens. One token at a time.
  defp handle_get_next_token(%Parser{current_char: current_char} = parser) do
    do_handle_get_next_token(current_char, parser)
  end

  defp do_handle_get_next_token(nil, parser) do
    struct(parser, current_token: Token.new(:eof, nil))
  end

  defp do_handle_get_next_token(" ", parser) do
    parser
    |> skip_whitespace()
    |> handle_get_next_token()
  end

  defp do_handle_get_next_token(current_char, parser)
       when current_char in @arithmetic_operators do
    {name, func} =
      case parser.current_char do
        "+" -> {:plus, &Kernel.+/2}
        "-" -> {:minus, &Kernel.-/2}
        "*" -> {:mult, &Kernel.*/2}
        "/" -> {:div, &Kernel.//2}
      end

    token = Token.new(name, func)

    parser
    |> advance()
    |> struct(current_token: token)
  end

  defp do_handle_get_next_token(current_char, parser) when current_char in @numbers do
    current_char = String.at(parser.text, parser.pos)
    next_char = String.at(parser.text, parser.pos + 1)

    acc = [current_char | parser.acc]

    if next_char in @numbers do
      parser
      |> advance()
      |> struct(acc: acc)
      |> handle_get_next_token()
    else
      acc_char = acc |> Enum.reverse() |> Enum.join("")
      token = Token.new(:integer, String.to_integer(acc_char))

      parser
      |> advance()
      |> struct(current_token: token, acc: [])
    end
  end

  defp advance(%Parser{} = parser) do
    pos = parser.pos + 1

    if parser.pos > String.length(parser.text) - 1 do
      struct(parser, current_char: nil, pos: pos)
    else
      current_char = String.at(parser.text, pos)
      struct(parser, current_char: current_char, pos: pos)
    end
  end

  defp skip_whitespace(%Parser{current_char: nil} = parser), do: parser

  defp skip_whitespace(%Parser{current_char: " "} = parser) do
    parser
    |> advance()
    |> skip_whitespace()
  end

  defp skip_whitespace(%Parser{} = parser), do: parser
end
