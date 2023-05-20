defmodule CalculatorTest do
  use ExUnit.Case

  describe "eval/1" do
    test "addition one digit" do
      assert Calculator.eval("1 + 1") == 2
      assert Calculator.eval("4 + 9") == 13
    end

    test "addition more digit" do
      assert Calculator.eval("10 + 1") == 11
      assert Calculator.eval("42 + 105") == 147
    end

    test "addition more operations" do
      assert Calculator.eval("10 - 1 + 2 ") == 11
      assert Calculator.eval("42 + 105 - 5 + 1 + 4") == 147
    end

    test "subtraction one digit" do
      assert Calculator.eval("1 - 1") == 0
      assert Calculator.eval("4 - 9") == -5
    end

    test "subtraction more digit" do
      assert Calculator.eval("10 - 1") == 9
      assert Calculator.eval("42 - 105") == -63
    end
  end
end
