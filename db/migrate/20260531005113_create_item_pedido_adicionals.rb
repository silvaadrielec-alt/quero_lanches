class CreateItemPedidoAdicionals < ActiveRecord::Migration[8.1]
  def change
    create_table :item_pedido_adicionals do |t|
      t.references :item_pedido, null: false, foreign_key: true
      t.references :insumo, null: false, foreign_key: true
      t.float :quantidade
      t.decimal :preco_unitario

      t.timestamps
    end
  end
end
