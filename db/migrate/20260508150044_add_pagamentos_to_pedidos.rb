class AddPagamentosToPedidos < ActiveRecord::Migration[8.1]
  def change
    add_column :pedidos, :pago_dinheiro, :decimal
    add_column :pedidos, :pago_pix, :decimal
    add_column :pedidos, :pago_cartao_debito, :decimal
    add_column :pedidos, :pago_cartao_credito, :decimal
  end
end
