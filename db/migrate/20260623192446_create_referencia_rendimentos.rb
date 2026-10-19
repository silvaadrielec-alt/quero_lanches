class CreateReferenciaRendimentos < ActiveRecord::Migration[8.1]
  def change
    create_table :referencia_rendimentos do |t|
      t.string :insumo_nome
      t.string :unidade_medida
      t.decimal :fator

      t.timestamps
    end
  end
end
