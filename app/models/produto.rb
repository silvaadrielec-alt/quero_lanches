class Produto < ApplicationRecord
  has_many :pedidos, dependent: :destroy
  has_many :movimentacaos, dependent: :destroy
  has_many :composicoes, class_name: "Composicao", foreign_key: "produto_id", dependent: :destroy
  has_many :insumos, through: :composicoes

  # Validações existentes
  validates :nome, presence: { message: "não pode ficar em branco" }
  validates :valor_unitario, presence: { message: "deve ser preenchido" }
  
  # Garante que se um código for digitado manualmente, ele seja exclusivo no sistema
  validates :codigo, uniqueness: { message: "já está cadastrado em outro produto", allow_blank: true }

  # Callback do Rails: Executa a lógica do código antes de validar o formulário
  before_validation :gerar_codigo_automatico

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

  # Método inteligente para o código da mercadoria
  def gerar_codigo_automatico
    if self.codigo.blank?
      # Descobre o maior ID atual no banco de dados (se o banco estiver vazio, assume 0)
      maior_id = Produto.maximum(:id).to_i
      proximo_id = maior_id + 1
      
      # .rjust(4, '0') garante que o número tenha sempre 4 dígitos (ex: 0001, 0012, 0145)
      self.codigo = "PRD-#{proximo_id.to_s.rjust(4, '0')}"
    else
      # Se o Davi preencheu algo, remove espaços nas pontas e força Letras Maiúsculas
      self.codigo = self.codigo.strip.upcase
    end
  end
end

