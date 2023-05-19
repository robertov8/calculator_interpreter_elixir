defmodule Calculator.Interpreter do
  defstruct text: nil, pos: 0, current_token: nil, current_char: nil, acc: []

  # import Calculator.Utils.Guards

  alias Calculator.{Token, Interpreter.Lexer}

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
  def exp(%__MODULE__{} = interpreter) do
    # set current token to the first token taken from the input

    current_interpreter = Lexer.get_next_token(interpreter)

    # # we expect the current token to be a single-digit integer
    left_interpreter = current_interpreter

    next_interpreter = eat(current_interpreter, :integer)

    # next_interpreter
    # we expect the current token to be a '+' token
    op_interpreter = next_interpreter

    next_interpreter = eat(next_interpreter, :plus)

    # # we expect the current token to be a single-digit integer
    right_interpreter = next_interpreter
    eat(next_interpreter, :integer)

    # after the above call the self.current_token is set to
    # EOF token

    # at this point INTEGER PLUS INTEGER sequence of tokens
    # has been successfully found and the method can just
    # return the result of adding two integers, thus
    # effectively interpreting client input

    apply(op_interpreter.current_token.value, [
      left_interpreter.current_token.value,
      right_interpreter.current_token.value
    ])

    # # left_interpreter.current_token.value + right_interpreter.current_token.value
  end

  @doc """
  compare the current token type with the passed token
  type and if they match then "eat" the current token
  and assign the next token to the self.current_token,
  otherwise raise an exception.
  """
  @spec eat(%__MODULE__{:current_token => %Token{}}, atom()) :: %__MODULE__{}
  def eat(%__MODULE__{current_token: %Token{} = current_token} = interpreter, token_type) do
    # IO.inspect(current_token.type)
    # IO.inspect(token_type)

    # IO.inspect(current_token, label: :eat_current_token)
    # IO.inspect(token_type, label: :eat_token_type)
    # dbg(current_token)

    if current_token.type == token_type do
      Lexer.get_next_token(interpreter)
    else
      raise "Error parsing input!"
    end
  end
end
