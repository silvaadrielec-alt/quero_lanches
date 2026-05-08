class Funcionario < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :pedidos
  validates :nome, presence: { message: "não pode ficar em branco" }

  # Definimos as unidades oficiais aqui (em minúsculo para o banco de dados)
  UNIDADES = [
    ["Matriz Centro", "centro"],
    ["Pavilhão Novo", "pavilhao_novo"],
    ["Pavilhão Antigo", "pavilhao_antigo"]
  ].freeze
  
  # Opcional: validação para garantir que só salvem unidades válidas
  validates :unidade, inclusion: { in: UNIDADES.map(&:last) }, allow_nil: true
end