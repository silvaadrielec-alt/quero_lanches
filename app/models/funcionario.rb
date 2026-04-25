class Funcionario < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Adicione estas linhas aqui:
  has_many :pedidos
  validates :nome, presence: { message: "não pode ficar em branco" }  
end
