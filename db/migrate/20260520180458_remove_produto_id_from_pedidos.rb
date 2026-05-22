class RemoveProdutoIdFromPedidos < ActiveRecord::Migration[7.1]
  def change
    # Remove as colunas antigas que agora pertencem exclusivamente ao carrinho (item_pedidos)
    remove_column :pedidos, :produto_id, :integer
    remove_column :pedidos, :quantidade, :integer
  end
end
