class AddLimitesDetalhadosToProdutos < ActiveRecord::Migration[8.1]
  def change
    add_column :produtos, :limite_centro, :integer
    add_column :produtos, :limite_pavilhao_novo, :integer
    add_column :produtos, :limite_pavilhao_antigo, :integer
  end
end
