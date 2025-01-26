defmodule Arvore do
  # Definindo os campos da struct
  defstruct chave: nil, val: nil, esquerdo: nil, direito: nil, x: nil, y: nil

  @scale 25  # Espaçamento entre os nós (definido no módulo)

  # Função principal do cálculo, é recursiva e calcula a posição dos nós da arvore determinando os valores de x e y

  def calcular_posicoes(nil, _nivel, limite_esquerdo), do: {nil, limite_esquerdo}

  # Nó é folha, ou seja, quando o nó não possui filho esquerdo e nem filho direito
  # usando o nivel para calcular a posição y para deteminar a altura
  # limite_esquerdo vai sendo ajustado ao percorrer a arvore para determinar onde vai ser colocada a posição x do nó
  def calcular_posicoes(%Arvore{esquerdo: nil, direito: nil} = no, nivel, limite_esquerdo) do
      no = %{no | y: @scale * nivel, x: limite_esquerdo}
      {no, limite_esquerdo + @scale}  # Atualizando o limite para o próximo nó
  end

  # Nó só tem filho esquerdo
  # função é chamada recursivamente para o filho esquerdo que estar a um nivel mais profundo incrementando + 1 ao nivel
  def calcular_posicoes(%Arvore{esquerdo: filho_esquerdo, direito: nil} = no, nivel, limite_esquerdo) do
      {filho_esquerdo, limite_direito} = calcular_posicoes(filho_esquerdo, nivel + 1, limite_esquerdo)
      no = %{no | esquerdo: filho_esquerdo, x: filho_esquerdo.x, y: @scale * nivel}
      {no, limite_direito}  # Atualizando o limite para o próximo nó, nó com as posiçoes atualizadas
  end

  # Nó só tem filho direito
  # função é chamada recursivamente para o filho direito que estar a um nivel mais profundo incrementando + 1 ao nivel
  def calcular_posicoes(%Arvore{esquerdo: nil, direito: filho_direito} = no, nivel, limite_esquerdo) do
      {filho_direito, limite_direito} = calcular_posicoes(filho_direito, nivel + 1, limite_esquerdo)
      no = %{no | direito: filho_direito, x: filho_direito.x, y: @scale * nivel}
      {no, limite_direito}  # Atualizando o limite para o próximo nó, nó com as posiçoes atualizadas
  end

  # Nó tem filho direito e filho esquerdo
  # função é chamada recursivamente para o filho esquerdo que estar a um nivel mais profundo incrementando + 1 ao nivel
  #limite_esquerdo representa a posição a esquerda do nó atual
  #limite_direito_filho_esquerdo usado para a posição inicial para o proximo calculo do nó direito
  #chamada recursiva tambem para o filho direito incrementando o nivel + 1
  #A posição do limite à esquerda do filho direito será calculada somando o limite_direito_filho_esquerdo com o valor do espaçamento entre os nós, para que o filho direito não sobreponha o esquerdo
  #o limite_direito_filho_direito será o limite à direita após a posição do filho direito
  #a posição x do nó atual é a média das posições x dos filhos esquerdo e direito
  #A posição y do nó é baseada no nível da árvore pelo scale, controlando o espaçamento entre os nós

  def calcular_posicoes(%Arvore{esquerdo: filho_esquerdo, direito: filho_direito} = no, nivel, limite_esquerdo) do
      # Primeiro, calcula as posições dos filhos
      {filho_esquerdo, limite_direito_filho_esquerdo} = calcular_posicoes(filho_esquerdo, nivel + 1, limite_esquerdo)
      {filho_direito, limite_direito_filho_direito} = calcular_posicoes(filho_direito, nivel + 1, limite_direito_filho_esquerdo + @scale)

      # Atualiza as posições do nó atual
      no = %{no | esquerdo: filho_esquerdo, direito: filho_direito, x: (filho_esquerdo.x + filho_direito.x) / 2.0, y: @scale * nivel}

      {no, limite_direito_filho_direito}  # Atualizando o limite para o próximo nó
  end

  # Imprimindo a árvore
  def imprimir(nil, _nivel), do: :ok

    def imprimir(%Arvore{chave: chave, val: val, esquerdo: esquerdo, direito: direito, x: x, y: y}, nivel) do
        IO.puts("#{chave} (#{val}) - x: #{x}, y: #{y}")

        if esquerdo != nil, do: imprimir(esquerdo, nivel + 1)
        if direito != nil, do: imprimir(direito, nivel + 1)
    end
end

defmodule Main do
  def main do
      # Criando a árvore da evolução
    no = %Arvore{
        chave: "Vida", val: 6,
        esquerdo: %Arvore{
          chave: "Organismos Unicelulares", val: 2,
          esquerdo: %Arvore{
            chave: "Procariotos", val: 1,
            esquerdo: nil, direito: nil,
            x: 0.0, y: 0.0
          },
          direito: %Arvore{
            chave: "Eucariotos", val: 4,
            esquerdo: %Arvore{
              chave: "Protistas", val: 3,
              esquerdo: nil, direito: nil,
              x: 0.0, y: 0.0
            },
            direito: %Arvore{
              chave: "Fungos", val: 5,
              esquerdo: nil, direito: nil,
              x: 0.0, y: 0.0
            }
          }
        },
        direito: %Arvore{
          chave: "Organismos Multicelulares", val: 8,
          esquerdo: %Arvore{
            chave: "Plantas", val: 7,
            esquerdo: nil, direito: nil,
            x: 0.0, y: 0.0
          },
          direito: %Arvore{
            chave: "Animais", val: 10,
            esquerdo: %Arvore{
              chave: "Invertebrados", val: 9,
              esquerdo: nil, direito: nil,
              x: 0.0, y: 0.0
            },
            direito: %Arvore{
              chave: "Vertebrados", val: 12,
              esquerdo: %Arvore{
                chave: "Peixes", val: 11,
                esquerdo: nil, direito: nil,
                x: 0.0, y: 0.0
              },
              direito: %Arvore{
                chave: "Mamíferos", val: 13,
                esquerdo: nil,
                direito: %Arvore{
                  chave: "Seres Humanos", val: 14,
                  esquerdo: nil, direito: nil,
                  x: 0.0, y: 0.0
                }
              }
            }
          }
        }
      }

      # Calcular as posições
      {no_mod, _} = Arvore.calcular_posicoes(no, 0, 0)

      # Imprimir a árvore
      Arvore.imprimir(no_mod, 0)
  end
end

Main.main()
