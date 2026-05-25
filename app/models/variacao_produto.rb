class VariacaoProduto < ApplicationRecord
  belongs_to :produto

  validates :tamanho, :preco_venda, presence: true
end
