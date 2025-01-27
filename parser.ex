#Define o módulo Parser que contém todas as funções dos tokens e gera a AST
defmodule Parser do
    #Ela recebe uma lista de tokens, chama parse_program para começar Se #parse_program retornar sucesso ela retorna a ast
    def parse(tokens) do
      case parse_program(tokens) do
        {:ok, result, _} -> {:ok, result}
        {:error, error} -> {:error, error}
      end
    end

    #program <id> ; <stat> end
    #A função parse_program analisa o programa começando com a palavra chave #program, seguida por um identificador, um ponto e vírgula e depois um #statement seguido pela palavra end, se os tokens correspondem ao formato ela #chama parse_statement e  verifica se a lista restante de tokens contém a #palavra-chave end e retorna o resultado
    def parse_program(tokens) do
      case tokens do
        [%{token: :program}, %{token: :id, value: id}, %{token: :semicolon} | rest] ->
          case parse_statement(rest) do
            {:ok, statement, rest} ->
              case rest do
                [%{token: :end} | rest] -> {:ok, %{program: id, statement: statement}, rest}
                _ -> {:error, "Expected 'end' after statement."}
              end
            {:error, error} -> {:error, error}
          end
        _ -> {:error, "Expected syntax: program <id> ; <stat> end"}
      end
    end

    #função processa múltiplas instruções em sequência separadas por ponto e #vírgula depois de verifica se há um ponto e vírgula continua tentando as #instruções subsequentes até que não haja mais
    def parse_statement_sequence(tokens) do
      case parse_statement(tokens) do
        {:ok, statement1, r1} ->
          case r1 do
            [%{token: :semicolon} | r2] ->
              case parse_statement_sequence(r2) do
                {:ok, statement2, rest} ->
                  {:ok, %{semicolon: [statement1, statement2]}, rest}
                {:error, error} -> {:error, error}
              end
            _ -> {:ok, statement1, r1}
          end
        {:error, error} -> {:error, error}
      end
    end

    #parse_statement lida com diferentes tipos de instruções no programa:
    #〈Stat〉 ::= begin { 〈Stat〉 ; } 〈Stat〉 end
    #〈Id〉 := 〈Expr〉
    #if 〈Comp〉 then 〈Stat〉 else 〈Stat〉
    #while 〈Comp〉 do 〈Stat〉
    #read 〈Id〉
    #write 〈Expr〉
    #Para cada tipo de instrução, a função tenta identificar os tokens correspondentes
    def parse_statement(tokens) do
      case tokens do
        [%{token: :begin} | r1] ->
          case parse_statement_sequence(r1) do
            {:ok, statement, r2} ->
              case r2 do
                [%{token: :end} | rest] -> {:ok, %{begin_end: statement}, rest}
                _ -> {:error, "Expected 'end'."}
              end
            {:error, error} -> {:error, error}
          end

        [%{token: :id, value: id}, %{token: :assign} | r1] ->
          case parse_expression(r1) do
            {:ok, expression, rest} ->
              {:ok, %{assign: %{id: id, expression: expression}}, rest}
            {:error, error} -> {:error, error}
          end

        [%{token: :if} | r1] ->
          case parse_comparison(r1) do
            {:ok, comparison, r2} ->
              case r2 do
                [%{token: :then} | r3] ->
                  case parse_statement(r3) do
                    {:ok, statement1, r4} ->
                      case r4 do
                        [%{token: :else} | r5] ->
                          case parse_statement(r5) do
                            {:ok, statement2, rest} ->
                              {:ok, %{if: %{comparison: comparison, statement1: statement1, statement2: statement2}}, rest}
                            {:error, error} -> {:error, error}
                          end
                        _ -> {:error, "Expected 'else'."}
                      end
                    {:error, error} -> {:error, error}
                  end
                _ -> {:error, "Expected 'then'."}
              end
            {:error, error} -> {:error, error}
          end

        [%{token: :while} | rest] ->
          case parse_comparison(rest) do
            {:ok, comparison, rest} ->
              case rest do
                [%{token: :do} | rest] ->
                  case parse_statement(rest) do
                    {:ok, statement, rest} ->
                      {:ok, %{while: %{comparison: comparison, statement: statement}}, rest}
                    {:error, error} -> {:error, error}
                  end
                _ -> {:error, "Expected 'do' after comparison."}
              end
            {:error, error} -> {:error, error}
          end

        [%{token: :read}, %{token: :id, value: id} | rest] ->
          {:ok, %{read: id}, rest}

        [%{token: :write} | rest] ->
          case parse_expression(rest) do
            {:ok, expression, rest} ->
              {:ok, %{write: expression}, rest}
            {:error, error} -> {:error, error}
          end

        _ -> {:error, "Invalid statement."}
      end
    end

    #lida com comparação: a > b
    def parse_comparison(tokens) do
      case parse_expression(tokens) do
        {:ok, expression1, rest} ->
          case rest do
            [%{token: :cop, value: op} | rest] ->
              case parse_expression(rest) do
                {:ok, expression2, rest} ->
                  {:ok, %{comparison: %{operator: op, expression1: expression1, expression2: expression2}}, rest}
                {:error, error} -> {:error, error}
              end
            _ -> {:error, "Expected COP after expression."}
          end
        {:error, error} -> {:error, error}
      end
    end

    #lida com expressões compostas por termos conectados por operadores
    def parse_expression(tokens) do
      case parse_term(tokens) do
        {:ok, term1, rest} ->
          case rest do
            [%{token: :eop, value: op} | rest] ->
              case parse_expression(rest) do
                {:ok, term2, rest} ->
                  {:ok, %{expression: %{operator: op, term1: term1, term2: term2}}, rest}
                {:error, error} -> {:error, error}
              end
            _ -> {:ok, term1, rest}
          end
        {:error, error} -> {:error, error}
      end
    end

    #lida com multiplicações e divisões
    def parse_term(tokens) do
      case parse_factor(tokens) do
        {:ok, factor1, rest} ->
          case rest do
            [%{token: :top, value: op} | rest] ->
              case parse_term(rest) do
                {:ok, factor2, rest} ->
                  {:ok, %{term: %{operator: op, factor1: factor1, factor2: factor2}}, rest}
                {:error, error} -> {:error, error}
              end
            _ -> {:ok, factor1, rest}
          end
        {:error, error} -> {:error, error}
      end
    end

    #lida com os elementos fundamentais de uma expressão, como números, variáveis e parênteses
    def parse_factor(tokens) do
      case tokens do
        [%{token: :integer, value: value} | rest] ->
          {:ok, %{factor: %{integer: value}}, rest}

        [%{token: :id, value: value} | rest] ->
          {:ok, %{factor: %{id: value}}, rest}

        [%{token: :lparen} | rest] ->
          case parse_expression(rest) do
            {:ok, expression, rest} ->
              case rest do
                [%{token: :rparen} | rest] ->
                  {:ok, expression, rest}
                _ -> {:error, "Expected )."}
              end
            {:error, error} -> {:error, error}
          end
        _ -> {:error, "Expected ID, Integer, or Expression."}
      end
    end

    #main com um exemplo de programa com todos os tokens possíveis
    def main() do
        # Programa de exemplo que usa todos os tokens
        tokens = [
          %{token: :program}, %{token: :id, value: "tokens"}, %{token: :semicolon}, # program tokens ;
          %{token: :begin}, # begin
            # stat 1    -->    a := 5;
            %{token: :id, value: "a"}, %{token: :assign}, %{token: :integer, value: 5}, %{token: :semicolon},

            # stat 2    -->    if a > 3 then write a else write 0;
            %{token: :if}, %{token: :id, value: "a"}, %{token: :cop, value: ">"}, %{token: :integer, value: 3}, %{token: :then},
              %{token: :write}, %{token: :id, value: "a"},
            %{token: :else},
              %{token: :write}, %{token: :integer, value: 0},
            %{token: :semicolon},

            # stat 3    -->    while a < 10 do a := a + 1;
            %{token: :while}, %{token: :id, value: "a"}, %{token: :cop, value: "<"}, %{token: :integer, value: 10}, %{token: :do},
              %{token: :id, value: "a"}, %{token: :assign}, %{token: :id, value: "a"}, %{token: :eop, value: "+"}, %{token: :integer, value: 1},
            %{token: :semicolon},

            # stat 4    -->    read b;
            %{token: :read}, %{token: :id, value: "b"}, %{token: :semicolon},

            # stat 5    -->    write (a * b)
            %{token: :write}, %{token: :lparen}, %{token: :id, value: "a"}, %{token: :top, value: "*"}, %{token: :id, value: "b"}, %{token: :rparen},
          %{token: :end}, # end
          %{token: :end} # end
        ]


        case Parser.parse(tokens) do
          {:ok, ast} -> IO.inspect(ast)
          {:error, error} -> IO.puts("Error: #{error}")
        end
      end
  end
  Parser.main()
