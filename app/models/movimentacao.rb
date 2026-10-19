class Movimentacao < ApplicationRecord
  self.table_name = 'movimentacaos'

  belongs_to :funcionario
  belongs_to :produto, optional: true
  belongs_to :insumo, optional: true
  belongs_to :unidade, optional: true
  belongs_to :item_pedido, optional: true
  
  validate :deve_ter_produto_ou_insumo
  validates :unidade_id, presence: { message: "é obrigatória para garantir o rastreio do estoque." }

  # --- CALLBACKS ---
  # Garante a auditoria ao criar e a gravação dos valores financeiros antes de salvar
  after_create :registrar_auditoria_financeira
  before_save :fixar_valores_financeiros

  # --- MÉTODO AUXILIAR PARA TRATAR O TIPO (REMOVE ACENTOS E MAIÚSCULAS) ---
  def tipo_normalizado
    I18n.transliterate(tipo_movimentacao.to_s.downcase)
  end

  # --- MÉTODOS DE CÁLCULO FINANCEIRO ---
 def valor_custo
    tipo = tipo_normalizado
    quantidade_f = quantidade.to_f

    if ['entrada', 'saida_transferencia'].include?(tipo)
      # Buscamos o preço do cadastro, garantindo que o objeto exista
      item = produto || insumo
      preco = item.respond_to?(:preco_custo) ? item.preco_custo.to_f : (item&.valor_unitario.to_f > 0 ? item.valor_unitario.to_f : 0.0)
      (quantidade_f * preco)
    else
      0.0
    end
  end

  def valor_receita
  # 1. Se já tem valor fixo, prioriza ele
  return read_attribute(:valor_receita) if read_attribute(:valor_receita).to_f > 0

  # 2. SE EXISTE O VÍNCULO, usa o preço exato do item do pedido (O jeito certo!)
  return (quantidade.to_f * item_pedido.preco_unitario.to_f).round(2) if item_pedido.present?

  # 3. Fallback (para casos antigos ou sem vínculo)
  tipo = tipo_normalizado
  quantidade_f = quantidade.to_f
  if (tipo.include?('saida') || tipo == 'venda') && !tipo.include?('transferencia') && (produto.present? || insumo.present?)
    item = produto || insumo
    preco_v = item.respond_to?(:preco_venda) ? item.preco_venda.to_f : 0.0
    (quantidade_f * preco_v).round(2)
  else
    0.0
  end
end

  private

  # Método que realmente grava os valores nas colunas do banco
  def fixar_valores_financeiros
    self.valor_receita = valor_receita if valor_receita.present?
  
  self.valor_custo = valor_custo
end

  def registrar_auditoria_financeira
    Auditoria.create!(
      acao: self.tipo_movimentacao || "ENTRADA",
      descricao: "Movimentação registrada para #{produto&.nome || insumo&.nome}",
      funcionario_id: self.funcionario_id,
      unidade_id: self.unidade_id,
      valor_novo: self.valor_custo,
      tabela_afetada: "movimentacaos"
    )
  end

  def deve_ter_produto_ou_insumo
    if produto_id.blank? && insumo_id.blank?
      errors.add(:base, "A movimentação de estoque deve estar vinculada a um Produto ou a um Insumo.")
    end
  end
end