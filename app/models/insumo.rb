class Produto < ApplicationRecord
  # (Código anterior do produto mantido aqui para referência visual de herança)
end

class Insumo < ApplicationRecord
  # 🌟 BLINDAGEM OPERACIONAL: impede que a deleção de uma matéria-prima 
  # destrua ou quebre receitas (fichas técnicas) de produtos existentes.
  has_many :movimentacaos, dependent: :destroy
  has_many :composicoes, class_name: "Composicao", foreign_key: "insumo_id", dependent: :restrict_with_error
  has_many :item_pedido_adicionais, dependent: :restrict_with_error

  # VALIDAÇÕES RÍGIDAS
  validates :nome, presence: { message: "não pode ficar em branco" }, uniqueness: { case_sensitive: false, message: "já está cadastrado no sistema" }
  validates :unidade_medida, presence: { message: "deve ser selecionada (UN, KG, LITRO, etc.)" }
  validates :preco_custo, presence: { message: "deve ser preenchido para cálculo de margem" }, numericality: { greater_than_or_equal_to: 0 }
  validates :limite_centro, :limite_pavilhao_novo, :limite_pavilhao_antigo, 
          presence: { message: "deve ser definido para controle de estoque" }, 
          numericality: { greater_than_or_equal_to: 0 }

  validates :media_unidades_kg, presence: true, numericality: { greater_than: 0 }

  before_validation :set_default_rendimento, on: :create

  def set_default_rendimento
    self.media_unidades_kg ||= 1.0
  end
    
  # LÓGICA DE ESTOQUE CRÍTICO REESTRUTURADA COM LIMITES POR FILIAL
  def precisa_reposicao?
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
end