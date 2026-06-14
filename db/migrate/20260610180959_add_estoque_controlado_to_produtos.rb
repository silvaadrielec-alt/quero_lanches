class AddEstoqueControladoToProdutos < ActiveRecord::Migration[8.1]
  def change
  add_column :produtos, :estoque_controlado, :boolean, default: true
  end
end
