class AddUnitStocksToProdutos < ActiveRecord::Migration[8.1]
  def change
    add_column :produtos, :estoque_centro, :integer
    add_column :produtos, :estoque_pavilhao_novo, :integer
    add_column :produtos, :estoque_pavilhao_antigo, :integer
  end
end
