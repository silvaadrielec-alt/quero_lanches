class Produto < ApplicationRecord
  has_many :pedidos, dependent: :destroy
  has_many :movimentacaos, dependent: :destroy
  has_many :composicoes, class_name: "Composicao", foreign_key: "produto_id", dependent: :destroy
  has_many :insumos, through: :composicoes
  
  # NOVA RELAÇÃO: Permite que um produto tenha múltiplos tamanhos precificados
  has_many :variacao_produtos, dependent: :destroy
  accepts_nested_attributes_for :variacao_produtos, allow_destroy: true, reject_if: :all_blank

  # Callback do Rails: Executa a lógica do código ANTES de validar o formulário
  before_validation :gerar_codigo_automatico

  # Validações existentes
  validates :nome, presence: { message: "não pode ficar em branco" }
  validates :valor_unitario, presence: { message: "deve ser preenchido" }
  
  # Garante a exclusividade real do código gerado ou digitado
  validates :codigo, uniqueness: { message: "já está cadastrado em outro produto" }

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

  private

  def gerar_codigo_automatico
    if self.codigo.blank?
      # Se o produto já existe no banco (caso do Tomate e Cebola antigos), usamos o ID dele!
      if self.id.present?
        id_referencia = self.id
      else
        # Se for um produto genuinamente novo, pega o próximo disponível
        id_referencia = (Produto.maximum(:id).to_i) + 1
      end
      
      # Garante os 4 dígitos com base no ID correto
      self.codigo = "PRD-#{id_referencia.to_s.rjust(4, '0')}"
    else
      # Se foi preenchido manualmente, limpa os espaços e força maiúsculas
      self.codigo = self.codigo.to_s.strip.upcase
    end
  end
end