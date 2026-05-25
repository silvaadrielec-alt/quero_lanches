class AddPrecoUnitarioToItemPedidos < ActiveRecord::Migration[7.1]
  def change
    add_column :item_pedidos, :preco_unitario, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
