class AddEstoqueMinimoToProdutos < ActiveRecord::Migration[8.1]
  def change
    add_column :produtos, :estoque_minimo, :integer
  end
end
