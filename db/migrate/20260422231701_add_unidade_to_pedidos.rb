class AddUnidadeToPedidos < ActiveRecord::Migration[8.1]
  def change
    add_column :pedidos, :unidade, :string
  end
end
