class Movimentacao < ApplicationRecord
  belongs_to :produto
  belongs_to :funcionario

  after_create :processar_transferencia

  private

  def processar_transferencia
    # 1. Retira do estoque do Centro
    novo_estoque_centro = self.produto.estoque_centro.to_i - self.quantidade
    self.produto.update(estoque_centro: novo_estoque_centro)

    # 2. Adiciona na unidade de destino
    case self.destino
    when "Pavilhão Novo"
      novo_valor = self.produto.estoque_pavilhao_novo.to_i + self.quantidade
      self.produto.update(estoque_pavilhao_novo: novo_valor)
    when "Pavilhão Antigo"
      novo_valor = self.produto.estoque_pavilhao_antigo.to_i + self.quantidade
      self.produto.update(estoque_pavilhao_antigo: novo_valor)
    end
  end
end
