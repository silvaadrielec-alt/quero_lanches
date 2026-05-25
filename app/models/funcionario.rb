class Funcionario < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :pedidos
  
  # Validações de presença obrigatória
  validates :nome, presence: { message: "não pode ficar em branco" }
  validates :cargo, presence: { message: "não pode ficar em branco" }

  # --- VALIDAÇÕES DE SEGURANÇA CONTRA LETRAS ---
  # Garante formato brasileiro de telefone: (XX) XXXX-XXXX ou (XX) XXXXX-XXXX (letras não passam)
  validates :telefone, format: { 
    with: /\A\(?\d{2}\)?\s?\d{4,5}-?\d{4}\z/, 
    message: "Inválido! Digite apenas números com o DDD (ex: 71999999999)" 
  }, allow_blank: true

  # Garante o formato de CPF padrão com ou sem pontos/traço: XXX.XXX.XXX-XX (letras não passam)
  validates :cpf, format: { 
    with: /\A\d{3}\.?\d{3}\.?\d{3}-?\d{2}\z/, 
    message: "Inválido! Certifique-se de digitar um CPF com 11 dígitos" 
  }, allow_blank: true

  # Definimos as unidades oficiais aqui (em minúsculo para o banco de dados)
  UNIDADES = [
    ["Matriz Centro", "centro"],
    ["Pavilhão Novo", "pavilhao_novo"],
    ["Pavilhão Antigo", "pavilhao_antigo"]
  ].freeze
  
  # Opcional: validação para garantir que só salvem unidades válidas
  validates :unidade, inclusion: { in: UNIDADES.map(&:last) }, allow_nil: true
end