class Pedido < ApplicationRecord
  belongs_to :produto
  belongs_to :cliente, optional: true
  belongs_to :funcionario

# Esse comando diz: "Depois de criar o pedido, execute o método baixar_estoque"
  after_create :baixar_estoque

 private

  def baixar_estoque
    case unidade
    when "centro"
      produto.update(estoque_centro: produto.estoque_centro - quantidade)
    when "pavilhao_novo"
      produto.update(estoque_pavilhao_novo: produto.estoque_pavilhao_novo - quantidade)
    when "pavilhao_antigo"
      produto.update(estoque_pavilhao_antigo: produto.estoque_pavilhao_antigo - quantidade)
    end # Fecha o case
  end   # Fecha o def baixar_estoque
end     # Fecha a class Pedido (Linha 21 no seu print)