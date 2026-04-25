class CreatePedidos < ActiveRecord::Migration[8.1]
  def change
    create_table :pedidos do |t|
      t.references :produto, null: false, foreign_key: true
      t.references :cliente, null: false, foreign_key: true
      t.references :funcionario, null: false, foreign_key: true
      t.integer :quantidade
      t.decimal :valor_total

      t.timestamps
    end
  end
end
