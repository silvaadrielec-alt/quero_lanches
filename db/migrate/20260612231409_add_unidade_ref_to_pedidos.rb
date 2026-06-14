class AddUnidadeRefToPedidos < ActiveRecord::Migration[8.1]
  def change
    add_reference :pedidos, :unidade, foreign_key: true
  end
end
