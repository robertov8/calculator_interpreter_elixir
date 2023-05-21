defmodule Calculator.Interpreter.Parser do
  use GenServer

  defstruct text: nil, pos: 0, current_token: nil, current_char: nil, acc: []

  alias Calculator.Interpreter
  alias Interpreter.{Lexer, Token}

  # Client
  def start_link(text) do
    GenServer.start_link(__MODULE__, text)
  end

  def expr(pid) do
    GenServer.call(pid, :expr)
  end

  # Callbacks

  @impl true
  def init(text) do
    {:ok, new(text)}
  end

  @impl true
  def handle_call(:expr, _from, parser) do
    {:ok, pid} = Lexer.start_link(parser)

    initial_parser = Lexer.get_next_token(pid)

    parser_term = term(initial_parser, pid)
    {parser, result} = do_expr(parser_term, initial_parser.current_token.value, pid)

    {:reply, result, parser}
  end

  defp new(text, fields \\ []) do
    default_fields = [
      text: text,
      current_char: String.at(text, 0),
      acc: []
    ]

    struct(__MODULE__, Keyword.merge(default_fields, fields))
  end

  # expr -> INTEGER PLUS INTEGER
  # set current token to the first token taken from the input
  defp do_expr(%__MODULE__{current_token: %Token{type: :eof}} = parser, acc, _pid) do
    {parser, acc}
  end

  defp do_expr(%__MODULE__{current_token: %Token{type: type}} = parser, acc, pid)
       when type in [:plus, :minus] do
    op_parser = eat(parser, type, pid)

    result = apply(parser.current_token.value, [acc, op_parser.current_token.value])

    parser_term = term(op_parser, pid)
    do_expr(parser_term, result, pid)
  end

  defp term(parser, pid) do
    eat(parser, :integer, pid)
  end

  # compare the current token type with the passed token
  # type and if they match then "eat" the current token
  # and assign the next token to the self.current_token,
  # otherwise raise an exception.
  @spec eat(%__MODULE__{:current_token => %Token{}}, atom(), pid) :: %__MODULE__{}
  defp eat(%__MODULE__{current_token: %Token{} = current_token}, token_type, pid) do
    if current_token.type == token_type do
      Lexer.get_next_token(pid)
    else
      raise "Error parsing input!"
    end
  end
end
