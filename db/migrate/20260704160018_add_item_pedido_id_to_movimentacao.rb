class AddItemPedidoIdToMovimentacao < ActiveRecord::Migration[8.1]
  def change
    add_column :movimentacaos, :item_pedido_id, :integer
  end
end
