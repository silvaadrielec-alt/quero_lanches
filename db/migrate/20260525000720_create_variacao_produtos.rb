class CreateVariacaoProdutos < ActiveRecord::Migration[8.1]
  def change
    create_table :variacao_produtos do |t|
      t.references :produto, null: false, foreign_key: true
      t.string :tamanho
      t.decimal :preco_venda

      t.timestamps
    end
  end
end
