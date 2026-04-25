class AddUnidadeMedidaToProdutos < ActiveRecord::Migration[8.1]
  def change
    add_column :produtos, :unidade_medida, :string
  end
end
