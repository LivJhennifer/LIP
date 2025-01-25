#testando
defmodule Calculator do
  def add(a, b) do
    a + b
  end
end

IO.puts("A soma de 5 e 3 é: #{Calculator.add(5, 3)}")
