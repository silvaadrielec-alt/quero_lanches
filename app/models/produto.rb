class Produto < ApplicationRecord
  has_many :pedidos, dependent: :destroy
  has_many :movimentacaos, dependent: :destroy
 has_many :composicoes, class_name: "Composicao", foreign_key: "produto_id", dependent: :destroy
  has_many :insumos, through: :composicoes

  # Adicione estas linhas abaixo:
  validates :nome, presence: { message: "não pode ficar em branco" }
  validates :valor_unitario, presence: { message: "deve ser preenchido" }

  def estoque_total
    estoque_centro.to_f + estoque_pavilhao_novo.to_f + estoque_pavilhao_antigo.to_f
  end

  # Métodos para checar cada unidade individualmente
  def estoque_centro_baixo?
    limite_centro.present? && estoque_centro.to_f <= limite_centro
  end

  def estoque_pavilhao_novo_baixo?
    limite_pavilhao_novo.present? && estoque_pavilhao_novo.to_f <= limite_pavilhao_novo
  end

  def estoque_pavilhao_antigo_baixo?
    limite_pavilhao_antigo.present? && estoque_pavilhao_antigo.to_f <= limite_pavilhao_antigo
  end

  # O alerta geral agora apita se QUALQUER uma das regras for atingida
  def precisa_reposicao?
    estoque_centro_baixo? || 
    estoque_pavilhao_novo_baixo? || 
    estoque_pavilhao_antigo_baixo? ||
    (estoque_minimo.to_f > 0 && estoque_total <= estoque_minimo.to_f)
  end
end

