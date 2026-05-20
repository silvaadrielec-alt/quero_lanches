class AddCodigoToProdutos < ActiveRecord::Migration[8.1]
  def change
    add_column :produtos, :codigo, :string
  end
end
