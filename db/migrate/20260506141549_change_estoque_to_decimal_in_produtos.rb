class ChangeEstoqueToDecimalInProdutos < ActiveRecord::Migration[8.1]
  def change
    # Alterando as colunas de estoque de Integer para Decimal
    # precision: 10 (total de dígitos), scale: 3 (casas após a vírgula)
    change_column :produtos, :estoque_centro, :decimal, precision: 10, scale: 3, default: 0
    change_column :produtos, :estoque_pavilhao_novo, :decimal, precision: 10, scale: 3, default: 0
    change_column :produtos, :estoque_pavilhao_antigo, :decimal, precision: 10, scale: 3, default: 0
    change_column :produtos, :estoque, :decimal, precision: 10, scale: 3, default: 0
  end
end
