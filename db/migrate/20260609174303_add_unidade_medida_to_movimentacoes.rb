class AddUnidadeMedidaToMovimentacoes < ActiveRecord::Migration[8.1]
  def change
    add_column :movimentacaos, :unidade_medida, :string
  end
end
