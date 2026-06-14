class AddPrecoUnitarioToItemPedidoAdicionais < ActiveRecord::Migration[8.0]
  def change
    # Force o nome da tabela aqui também para garantir
    #add_column :item_pedido_adicionals, :preco_unitario, :decimal, precision: 10, scale: 2
  end
end
