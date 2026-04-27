class Pedido < ApplicationRecord
  belongs_to :produto
  belongs_to :cliente, optional: true
  belongs_to :funcionario

  # Adicione esta linha para o Rails aceitar os ingredientes do formulário
  attr_accessor :ingredientes_removidos

  after_create :baixar_estoque

  private

  def baixar_estoque
    # 1. Baixa o produto principal (o que foi vendido)
    case unidade
    when 'centro'
      produto.update!(estoque_centro: produto.estoque_centro - quantidade)
    when 'pavilhao_novo'
      produto.update!(estoque_pavilhao_novo: produto.estoque_pavilhao_novo - quantidade)
    when 'pavilhao_antigo'
      produto.update!(estoque_pavilhao_antigo: produto.estoque_pavilhao_antigo - quantidade)
    end

    # 2. Baixa os insumos da "receita" (SÓ se não foram removidos no checkout)
    produto.composicoes.each do |comp|
      # Se o ingrediente_id NÃO estiver na lista de removidos (ou se a lista estiver vazia), ele baixa
      if ingredientes_removidos.nil? || ingredientes_removidos.include?(comp.insumo_id.to_s)
        insumo = comp.insumo
        quantidade_gasta = comp.quantidade * self.quantidade

        case unidade
        when 'centro'
          insumo.update!(estoque_centro: insumo.estoque_centro - quantidade_gasta)
        when 'pavilhao_novo'
          insumo.update!(estoque_pavilhao_novo: insumo.estoque_pavilhao_novo - quantidade_gasta)
        when 'pavilhao_antigo'
          insumo.update!(estoque_pavilhao_antigo: insumo.estoque_pavilhao_antigo - quantidade_gasta)
        end
      end
    end # Fim do each
  end # Fim do def (Este é o que estava faltando!)
end # Fim da class