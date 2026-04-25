class ChangeClienteIdToBeNullableInPedidos < ActiveRecord::Migration[8.1]
  def change
  change_column_null :pedidos, :cliente_id, true
end
end
