class Despesa < ApplicationRecord
  belongs_to :funcionario
  belongs_to :unidade

  attribute :data_pagamento, :date
  attribute :data_vencimento, :date

  CATEGORIAS = [
    "Água/Luz/Internet", 
    "Pagamento Funcionário", 
    "Compra de Mercadoria", 
    "Produtos de Limpeza", 
    "Serviços de Limpeza", 
    "Outros"
  ]

  validates :descricao, :valor, :categoria, :unidade, :turno, presence: true
  validates :data_pagamento, presence: true, if: :pago?
  validates :data_vencimento, presence: true, unless: :pago?
  validate :verificar_duplicidade, on: :create

  def auditar_alteracao(funcionario_id)
    # Garante que só audita se algo REALMENTE mudou
    if saved_changes.slice(:valor, :descricao, :pago).any?
      Auditorium.create!(
        funcionario_id: funcionario_id,
        tabela_afetada: 'Despesas',
        registro_id: self.id,
        unidade: self.unidade || 'GERAL',
        acao: 'ALTERAÇÃO',
        valor_anterior: saved_changes['valor']&.first || self.valor,
        valor_novo: saved_changes['valor']&.last || self.valor,
        descricao: "Despesa ##{self.id} ('#{self.descricao}') alterada. Status pago: #{self.pago}"
      )
    end
  end

  def auditar_exclusao(funcionario_id)
    Auditorium.create!(
      funcionario_id: funcionario_id,
      tabela_afetada: 'Despesas',
      registro_id: self.id,
      unidade: self.unidade || 'GERAL',
      acao: 'EXCLUSÃO',
      valor_anterior: self.valor,
      valor_novo: nil,
      descricao: "ALERTA: Despesa ##{self.id} ('#{self.descricao}') de R$ #{self.valor} EXCLUÍDA."
    )
  end

  private

  def verificar_duplicidade
    return unless descricao.present?
    
    # Busca apenas nos últimos 30 dias para não ficar lento
    duplicada = Despesa.where(unidade: unidade, valor: valor)
                       .where("created_at > ?", 30.days.ago)
                       .where("LOWER(TRIM(descricao)) = ?", descricao.to_s.strip.downcase)
                       .exists?

    errors.add(:base, "⚠️ ALERTA: Despesa duplicada detectada na mesma unidade.") if duplicada
  end
end