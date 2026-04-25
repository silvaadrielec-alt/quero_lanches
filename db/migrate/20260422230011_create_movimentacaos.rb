class CreateMovimentacaos < ActiveRecord::Migration[8.1]
  def change
    create_table :movimentacaos do |t|
      t.references :produto, null: false, foreign_key: true
      t.string :origem
      t.string :destino
      t.integer :quantidade
      t.references :funcionario, null: false, foreign_key: true

      t.timestamps
    end
  end
end
