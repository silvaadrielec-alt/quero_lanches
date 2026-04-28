class AddPrecoVendaToProdutos < ActiveRecord::Migration[8.1]
  def change
    add_column :produtos, :preco_venda, :decimal
  end
end
