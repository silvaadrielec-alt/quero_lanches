class Despesa < ApplicationRecord
  # ASSOCIAÇÃO: Permite que o controller vincule o funcionário logado à despesa
  belongs_to :funcionario

  CATEGORIAS = [
    "Água/Luz/Internet", 
    "Pagamento Funcionário", 
    "Compra de Mercadoria", 
    "Produtos de Limpeza", 
    "Serviços de Limpeza", 
    "Outros"
  ]

  # VALIDAÇÕES: Garante que os dados essenciais não fiquem vazios
  validates :descricao, :valor, :categoria, :data_pagamento, presence: true
  validates :unidade, :turno, presence: true # Importante para o filtro de faturamento
end