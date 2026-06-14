class AddEstoqueMinimoToInsumos < ActiveRecord::Migration[8.1]
  def change
    add_column :insumos, :estoque_minimo, :decimal
  end
end
