class AddIdentificadorToPedidos < ActiveRecord::Migration[8.1]
  def change
    add_column :pedidos, :identificador, :string
  end
end
