class Despesa < ApplicationRecord
  # ASSOCIAÇÃO
  belongs_to :funcionario

  # SOLUÇÃO DEFINITIVA: Força o Rails a tratar os campos como Date puro, eliminando o erro de horas nas views
  attribute :data_pagamento, :date
  attribute :data_vencimento, :date

  CATEGORIAS = [
    "Água/Luz/Internet", 
    "Pagamento Funcionário", 
    "Compra de Mercadoria", 
    "Produtos de Limpeza", 
    "Serviços de Limpeza", 
    "Outros"
  ]

  # VALIDAÇÕES
  validates :descricao, :valor, :categoria, :data_pagamento, :unidade, :turno, presence: true
  
  # Trava de segurança contra duplicidade
  validate :verificar_duplicidade, on: :create

  private

  def verificar_duplicidade
    # 1. Limpamos a descrição: remove espaços nas pontas e deixa tudo em minúsculo
    descricao_limpa = descricao.to_s.strip.downcase
    
    # 2. Procuramos se já existe algo igual hoje nesta unidade
    duplicada = Despesa.where(unidade: unidade, data_pagamento: data_pagamento, valor: valor)
                       .where("LOWER(TRIM(descricao)) = ?", descricao_limpa)
                       .exists?

    if duplicada
      errors.add(:base, "⚠️ ALERTA DE DUPLICIDADE: Já existe um lançamento de '#{descricao}' com o valor de R$ #{valor} para hoje nesta unidade. Verifique se a despesa já foi cadastrada por outro turno.")
    end
  end
end