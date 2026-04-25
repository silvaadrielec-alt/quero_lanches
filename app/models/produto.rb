class Produto < ApplicationRecord
  has_many :pedidos, dependent: :destroy
  has_many :movimentacaos, dependent: :destroy

  # Adicione estas linhas abaixo:
  validates :nome, presence: { message: "não pode ficar em branco" }
  validates :valor_unitario, presence: { message: "deve ser preenchido" }
end
