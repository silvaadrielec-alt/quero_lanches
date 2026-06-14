class Movimentacao < ApplicationRecord
  # Define que este model usa a tabela 'movimentacaos'
  self.table_name = 'movimentacaos'

  # Relacionamentos
  belongs_to :funcionario
  belongs_to :produto, optional: true
  belongs_to :insumo, optional: true
  belongs_to :unidade, optional: true
  
  # Validação para garantir que o log nunca seja criado sem nenhum destino
  validate :deve_ter_produto_ou_insumo

  # --- MÉTODOS DE CÁLCULO FINANCEIRO ---

  def valor_custo
  # Garante que compara com string minúscula para não falhar
  if insumo.present? && tipo_movimentacao.to_s.downcase == 'entrada'
    (quantidade.to_f * insumo.preco_custo.to_f)
  elsif produto.present? && tipo_movimentacao.to_s.downcase == 'entrada'
    (quantidade.to_f * produto.valor_unitario.to_f)
  else
    0.0
  end
end

def valor_receita
  # Ajustado para aceitar várias formas de saída
  if produto.present? && (tipo_movimentacao.to_s.downcase.include?('saida') || tipo_movimentacao.to_s.downcase == 'venda')
    (quantidade.to_f * produto.preco_venda.to_f)
  elsif insumo.present? && (tipo_movimentacao.to_s.downcase.include?('saida') || tipo_movimentacao.to_s.downcase == 'adicional')
    (quantidade.to_f * insumo.preco_venda.to_f)
  else
    0.0
  end
end

  private

  def deve_ter_produto_ou_insumo
    if produto_id.blank? && insumo_id.blank?
      errors.add(:base, "A movimentação de estoque deve estar vinculada a um Produto ou a um Insumo.")
    end
  end
end