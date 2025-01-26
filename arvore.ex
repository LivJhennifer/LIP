#modolo para oganizar as funções
defmodule Arvore do
    #definindo os campos da struct
    defstruct chave: nil, val: nil, esquerdo: nil, direito: nil, x: nil, y: nil

    @scale 25 #espaçamento entre os nós

    # #função pra construção da struct com valores
    # def no(key, val, left, right, x, y) do
    #     %arvore{key: key, val: val, left: left, right: right, x: x, y: y}
    # end

    #função principal do calculo
    def calcular_posicoes(nil, _nivel, limite_esquerdo), do: {nil, limite_esquerdo}

    #nó é folha
    def calcular_posicoes(%Arvore{esquerdo: nil, direito: nil} = no, nivel, scale, limite_esquerdo) do
        no = %{no | y: scale*nivel, x: limite_esquerdo}
        {no, limite_esquerdo}
    end

    #nó só tem filho esquerdo
    def calcular_posicoes(%Arvore{esquerdo: filho_esquerdo, direito: nil} = no, nivel, scale, limite_esquerdo) do
        {filho_esquerdo, limite_direito} = calcular_posicoes(filho_esquerdo, nivel + 1, scale, limite_esquerdo)
        no = %{no | esquerdo: filho_esquerdo, x: filho_esquerdo.x, y: scale*nivel}
        {no, limite_direito}
    end

    #nó só tem filho direito
    def calcular_posicoes(%Arvore{esquerdo: nil, direito: filho_direito} = no, nivel, scale, limite_esquerdo) do
        {filho_direito, limite_direito} = calcular_posicoes(filho_direito, nivel + 1, scale, limite_esquerdo)
        no = %{no | direito: filho_direito, x: filho_direito.x, y: scale*nivel}
        {no, limite_direito}
    end

    #nó tem filho direito e filho esquerdo
    def calcular_posicoes(%Arvore{esquerdo: nil, direito: filho_direito} = no, nivel, scale, limite_esquerdo) do
        {filho_direito, limite_direito_filho_direito} = calcular_posicoes(filho_direito, nivel + 1, scale, limite_direito_filho_esquerdo + scale)
        {filho_esquerdo, limite_direito_filho_esquerdo} = calcular_posicoes(filho_esquerdo, nivel + 1, scale, limite_esquerdo)
        no = %{no | esquerdo: filho_esquerdo, direito: filho_direito, x: (filho_esquerdo.x + filho_direito.x)/2.00, y: scale*nivel}
        {no, limite_direito_filho_direito}
    end

    #imprimindo a arvore
    def imprimir(nil, _nivel), do: :ok

    def imprimir(%Arvore{chave: chave, val: val, esquerdo: esquerdo, direito: direito, x: x, y: y}, nivel) do
      IO.puts(String.duplicate("  ", nivel) <> "#{chave} (#{val}) - x: #{x}, y: #{y}")
      if esquerdo != nil, do: imprimir(esquerdo, nivel + 1)
      if direito != nil, do: imprimir(direito, nivel + 1)
    end
end

defmodule Main do
    def main do
        #criando arvore
        no = %Arvore{
            chave: "A", val: 111,
            esquerdo: %Arvore{
                chave: "B", val: 55,
                esquerdo: %Arvore{
                    chave: "X", val: 101,
                    esquerdo: %Arvore{
                        chave: "Z", val: 58,
                        esquerdo: nil, direito: nil,
                        x: 0.0, y: 0.0
                    }, direito: %Arvore{
                        chave: "W", val: 32,
                        esquerdo: nil, direito: nil,
                        x: 0.0, y: 0.0
                    }
                }, direito: %Arvore{
                    chave: "Y", val: 106,
                    esquerdo: nil, direito: %Arvore{
                        chave: "R", val: 78,
                        esquerdo: nil, direito: nil, x: 0.0, y: 0.0
                    }
                }
            }, direito: %Arvore{
                chave: "C", val: 123,
                esquerdo: %Arvore{
                    chave: "D", val: 119,
                    esquerdo: %Arvore{
                        chave: "G", val: 44,
                        esquerdo: nil, direito: nil, x: 0.0, y: 0.0
                    }, direito: %Arvore{
                        chave: "H", val: 50,
                        esquerdo: %Arvore{
                            chave: "I", val: 5,
                            esquerdo: nil, direito: nil, x: 0.0, y: 0.0
                        }, direito: %Arvore{
                            chave: "j", val: 6, esquerdo: nil,
                            direito: nil, x: 0.0, y: 0.0
                        }
                    }
                }, direito: %Arvore{
                    chave: "E", val: 133,
                    esquerdo: nil, direito: nil, x: 0.0, y: 0.0
                }
            }
        }
        #calcular as posições
        {no_mod, _} = Arvore.calcular_posicoes(no, 0, 0)

        #imprimir a arvore
        Arvore.imprimir(no_mod, 0)
    end

end

Main.main()
