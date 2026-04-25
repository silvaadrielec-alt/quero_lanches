class AddCategoriaToProdutos < ActiveRecord::Migration[8.1]
  def change
    add_column :produtos, :categoria, :string
  end
end
