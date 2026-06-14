class AddLimitesEspecificosToInsumos < ActiveRecord::Migration[8.1]
  def change
    add_column :insumos, :limite_centro, :decimal
    add_column :insumos, :limite_pavilhao_novo, :decimal
    add_column :insumos, :limite_pavilhao_antigo, :decimal
  end
end
