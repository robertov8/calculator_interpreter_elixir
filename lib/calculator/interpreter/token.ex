defmodule Calculator.Interpreter.Token do
  defstruct type: nil, value: nil

  def new(type, value) do
    %__MODULE__{
      type: type,
      value: value
    }
  end
end
