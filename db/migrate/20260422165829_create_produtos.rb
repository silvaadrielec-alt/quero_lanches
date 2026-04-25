class CreateProdutos < ActiveRecord::Migration[8.1]
  def change
    create_table :produtos do |t|
      t.string :nome
      t.decimal :valor_unitario
      t.integer :estoque

      t.timestamps
    end
  end
end
