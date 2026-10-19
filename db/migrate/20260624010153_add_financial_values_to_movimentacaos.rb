class AddFinancialValuesToMovimentacaos < ActiveRecord::Migration[8.1]
  def change
    add_column :movimentacaos, :valor_custo, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :movimentacaos, :valor_receita, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
