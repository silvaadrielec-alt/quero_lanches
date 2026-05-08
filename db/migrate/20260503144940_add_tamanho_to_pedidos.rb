class AddTamanhoToPedidos < ActiveRecord::Migration[8.1]
  def change
    add_column :pedidos, :tamanho, :string
  end
end
