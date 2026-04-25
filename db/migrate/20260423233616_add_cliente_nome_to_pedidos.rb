class AddClienteNomeToPedidos < ActiveRecord::Migration[8.1]
  def change
    add_column :pedidos, :cliente_nome, :string
  end
end
