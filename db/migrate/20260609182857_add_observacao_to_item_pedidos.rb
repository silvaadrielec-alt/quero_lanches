class AddObservacaoToItemPedidos < ActiveRecord::Migration[8.1]
  def change
    add_column :item_pedidos, :observacao, :string
  end
end
