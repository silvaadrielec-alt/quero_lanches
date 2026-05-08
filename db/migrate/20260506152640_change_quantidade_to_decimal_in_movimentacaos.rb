class ChangeQuantidadeToDecimalInMovimentacaos < ActiveRecord::Migration[8.1]
  def change
    # Alterando de Integer para Decimal para aceitar 1.7, 2.5, etc.
    change_column :movimentacaos, :quantidade, :decimal, precision: 10, scale: 3
  end
end
