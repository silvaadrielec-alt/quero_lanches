class Funcionario < ApplicationRecord
  attr_accessor :total_vendas

  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # RELACIONAMENTOS
  has_many :pedidos
  belongs_to :unidade, optional: true # Agora o funcionário aponta para uma unidade real

  # VALIDAÇÕES
  validates :nome, presence: { message: "não pode ficar em branco" }
  validates :cargo, presence: { message: "não pode ficar em branco" }
  # Exigimos que a unidade esteja preenchida para garantir consistência
  validates :unidade, presence: { message: "é obrigatória" } 

  # --- VALIDAÇÕES DE SEGURANÇA ---
  validates :telefone, format: { 
    with: /\A\(?\d{2}\)?\s?\d{4,5}-?\d{4}\z/, 
    message: "Inválido! Digite apenas números com o DDD (ex: 71999999999)" 
  }, allow_blank: true

  validates :cpf, format: { 
    with: /\A\d{3}\.?\d{3}\.?\d{3}-?\d{2}\z/, 
    message: "Inválido! Certifique-se de digitar um CPF com 11 dígitos" 
  }, allow_blank: true
end