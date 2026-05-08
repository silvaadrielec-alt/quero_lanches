class AddMediaUnidadesKgToProdutos < ActiveRecord::Migration[8.1]
  def change
    add_column :produtos, :media_unidades_kg, :decimal, precision: 10, scale: 2, default: 1.0
  end
end
