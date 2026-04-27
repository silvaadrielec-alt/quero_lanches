class AddInsumoToProdutos < ActiveRecord::Migration[8.1]
  def change
    add_column :produtos, :insumo, :boolean
  end
end
