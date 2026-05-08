class CreateDespesas < ActiveRecord::Migration[8.1]
  def change
    create_table :despesas do |t|
      t.string :descricao
      t.string :categoria
      t.decimal :valor
      t.date :data_pagamento
      t.boolean :pago

      t.timestamps
    end
  end
end
