class ItemPedidoAdicional < ApplicationRecord
  self.table_name = "item_pedido_adicionals"
  belongs_to :item_pedido
  belongs_to :insumo

  
   validates :preco_unitario, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
