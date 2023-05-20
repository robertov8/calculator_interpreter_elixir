defmodule Calculator.Interpreter.Parser do
  defstruct text: nil, pos: 0, current_token: nil, current_char: nil, acc: []

  alias Calculator.Interpreter
  alias Interpreter.{Lexer, Token}

  def new(text, fields \\ []) do
    default_fields = [
      text: text,
      current_char: String.at(text, 0),
      acc: []
    ]

    struct(__MODULE__, Keyword.merge(default_fields, fields))
  end

  @doc """
  expr -> INTEGER PLUS INTEGER

  set current token to the first token taken from the input
  """
  def expr(%__MODULE__{} = parser) do
    initial_parser = Lexer.get_next_token(parser)

    initial_parser
    |> term()
    |> do_expr(initial_parser.current_token.value)
  end

  defp do_expr(%__MODULE__{current_token: %Token{type: :eof}} = _parser, acc) do
    acc
  end

  defp do_expr(%__MODULE__{current_token: %Token{type: type}} = parser, acc)
       when type in [:plus, :minus] do
    op_parser = eat(parser, type)

    result = apply(parser.current_token.value, [acc, op_parser.current_token.value])

    op_parser
    |> term()
    |> do_expr(result)
  end

  defp term(parser), do: eat(parser, :integer)

  # compare the current token type with the passed token
  # type and if they match then "eat" the current token
  # and assign the next token to the self.current_token,
  # otherwise raise an exception.
  @spec eat(%__MODULE__{:current_token => %Token{}}, atom()) :: %__MODULE__{}
  defp eat(%__MODULE__{current_token: %Token{} = current_token} = parser, token_type) do
    if current_token.type == token_type do
      Lexer.get_next_token(parser)
    else
      raise "Error parsing input!"
    end
  end
end
