class AddTurnoToPedidos < ActiveRecord::Migration[8.1]
  def change
    add_column :pedidos, :turno, :string
  end
end
