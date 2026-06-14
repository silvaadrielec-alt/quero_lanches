class RemoveUnidadeFromPedidos < ActiveRecord::Migration[8.1]
  def change
    remove_column :pedidos, :unidade, :string
  end
end
