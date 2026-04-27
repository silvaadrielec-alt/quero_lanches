class Produto < ApplicationRecord
  has_many :pedidos, dependent: :destroy
  has_many :movimentacaos, dependent: :destroy
 has_many :composicoes, class_name: "Composicao", foreign_key: "produto_id", dependent: :destroy
  has_many :insumos, through: :composicoes

  # Adicione estas linhas abaixo:
  validates :nome, presence: { message: "não pode ficar em branco" }
  validates :valor_unitario, presence: { message: "deve ser preenchido" }
end
