class Produto < ApplicationRecord

  attr_accessor :total_vendido

  # 🌟 BLINDAGEM HISTÓRICA
  has_many :item_pedidos, dependent: :restrict_with_error
  has_many :movimentacaos, dependent: :destroy
  
  has_many :composicoes, class_name: "Composicao", foreign_key: "produto_id", dependent: :destroy
  has_many :insumos, through: :composicoes
  
  has_many :variacao_produtos, dependent: :destroy
  accepts_nested_attributes_for :variacao_produtos, allow_destroy: true, reject_if: :all_blank

  # --- CALLBACKS ---
  before_validation :gerar_codigo_automatico
  before_validation :garantir_valores_numericos

  # Validações unificadas
  validates :nome, presence: { message: "não pode ficar em branco" }
  validates :preco_venda, presence: { message: "deve ser preenchido" }, numericality: { greater_than_or_equal_to: 0 }
  validates :limite_centro, :limite_pavilhao_novo, :limite_pavilhao_antigo, 
            numericality: { greater_than_or_equal_to: 0 },
            if: -> { estoque_controlado? }
  validates :codigo, uniqueness: { message: "já está cadastrado em outro produto" }

  # LÓGICA DE ESTOQUE CRÍTICO
  def precisa_reposicao?
    return false if composicoes.any?
    estoque_centro_baixo? || estoque_pavilhao_novo_baixo? || estoque_pavilhao_antigo_baixo?
  end

  def estoque_centro_baixo?
    estoque_centro.to_f < limite_centro.to_f
  end

  def estoque_pavilhao_novo_baixo?
    estoque_pavilhao_novo.to_f < limite_pavilhao_novo.to_f
  end

  def estoque_pavilhao_antigo_baixo?
    estoque_pavilhao_antigo.to_f < limite_pavilhao_antigo.to_f
  end
  
  private

  def garantir_valores_numericos
    # Define 0.0 se estiverem vazios, evitando nil no banco
    self.valor_unitario ||= 0.0
    self.preco_venda ||= 0.0
  end

  def gerar_codigo_automatico
    if self.codigo.blank?
      id_referencia = self.id.present? ? self.id : (Produto.maximum(:id).to_i + 1)
      self.codigo = "PRD-#{id_referencia.to_s.rjust(4, '0')}"
    else
      self.codigo = self.codigo.to_s.strip.upcase
    end
  end
end