class Pedido < ApplicationRecord
  include EstoqueCalculavel # O motor de estoque agora está aqui

  has_many :item_pedidos, dependent: :destroy
  belongs_to :cliente, optional: true
  belongs_to :funcionario
  belongs_to :unidade

  accepts_nested_attributes_for :item_pedidos, allow_destroy: true, reject_if: :all_blank

  validate :verificar_disponibilidade_estoque, on: :create
  validate :verificar_pagamento, on: :create
  validates :valor_total, numericality: { greater_than: 0, message: "não pode ser zero." }

  # --- MÉTODOS FINANCEIROS ---
  def total_pago; (pago_dinheiro.to_f + pago_pix.to_f + pago_cartao_debito.to_f + pago_cartao_credito.to_f).round(2); end
  
  def calcular_troco
    pago_eletronico = pago_pix.to_f + pago_cartao_debito.to_f + pago_cartao_credito.to_f
    saldo_restante = valor_total.to_f - pago_eletronico
    (pago_dinheiro.to_f - saldo_restante).clamp(0, Float::INFINITY).round(2)
  end

  def recalcular_valor_total
    total = item_pedidos.sum do |item|
      preco_item = item.produto&.preco_venda.to_f
      item.preco_unitario = preco_item
      total_ads = item.item_pedido_adicionais.sum { |ipa| (ipa.preco_unitario.to_f > 0 ? ipa.preco_unitario.to_f : ipa.insumo&.preco_venda.to_f) * ipa.quantidade.to_f }
      (preco_item * item.quantidade.to_f) + total_ads
    end
    self.valor_total = total.round(2)
  end

  def auditar_cancelamento(funcionario_id)
    return unless defined?(Auditoria)
    Auditoria.create!(funcionario_id: funcionario_id, tabela_afetada: 'Pedidos', registro_id: id, unidade_id: unidade_id, acao: 'CANCELAMENTO', valor_anterior: valor_total, valor_novo: 0.0, descricao: "Venda ##{id} CANCELADA. Estoque estornado.")
  end

  private
  # O verificar_disponibilidade_estoque deve permanecer aqui, mas pode chamar os métodos 
  # do EstoqueCalculavel (ex: calcular_quantidade_real) se desejar.
  def verificar_pagamento
    if valor_total.to_f > 0 && total_pago < valor_total.to_f
      errors.add(:base, "O valor pago (R$ #{total_pago}) é menor que o total.")
    end
  end
end