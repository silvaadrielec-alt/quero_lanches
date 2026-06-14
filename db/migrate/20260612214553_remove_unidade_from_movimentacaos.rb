class RemoveUnidadeFromMovimentacaos < ActiveRecord::Migration[8.1]
  def change
    remove_column :movimentacaos, :unidade, :string
  end
end
