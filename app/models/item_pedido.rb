class ItemPedido < ApplicationRecord
  belongs_to :pedido
  belongs_to :produto
  
  # 🌟 CORREÇÃO DE INFLEXÃO: Aponta explicitamente para o nome real da classe no singular
  has_many :item_pedido_adicionais, class_name: "ItemPedidoAdicional", dependent: :destroy
  
  accepts_nested_attributes_for :item_pedido_adicionais, allow_destroy: true, reject_if: :all_blank
end