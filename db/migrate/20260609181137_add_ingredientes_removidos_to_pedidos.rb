class AddIngredientesRemovidosToPedidos < ActiveRecord::Migration[8.1]
  def change
    add_column :pedidos, :ingredientes_removidos, :string
  end
end
