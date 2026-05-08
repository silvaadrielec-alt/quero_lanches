class AddObservacaoToPedidos < ActiveRecord::Migration[8.1]
  def change
    add_column :pedidos, :observacao, :text
  end
end
