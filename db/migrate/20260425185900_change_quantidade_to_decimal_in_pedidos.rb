class ChangeQuantidadeToDecimalInPedidos < ActiveRecord::Migration[7.0]
  def change
    # Mudando de Integer para Decimal com 3 casas decimais (para aceitar 0.100 gramas)
    change_column :pedidos, :quantidade, :decimal, precision: 10, scale: 3
  end
end
