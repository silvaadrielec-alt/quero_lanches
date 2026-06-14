class CreateInsumos < ActiveRecord::Migration[8.1]
  def change
    create_table :insumos do |t|
      t.string :nome
      t.decimal :preco_venda, precision: 10, scale: 2, default: 0.0
      t.decimal :estoque_centro, precision: 10, scale: 3, default: 0.0
      t.decimal :estoque_pavilhao_novo, precision: 10, scale: 3, default: 0.0
      t.decimal :estoque_pavilhao_antigo, precision: 10, scale: 3, default: 0.0
      t.decimal :media_unidades_kg, precision: 10, scale: 3, default: 0.0

      t.timestamps
    end
  end
end
