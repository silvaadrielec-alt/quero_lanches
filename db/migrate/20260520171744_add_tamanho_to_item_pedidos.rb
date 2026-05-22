class AddTamanhoToItemPedidos < ActiveRecord::Migration[8.1]
  def change
    add_column :item_pedidos, :tamanho, :string
  end
end
