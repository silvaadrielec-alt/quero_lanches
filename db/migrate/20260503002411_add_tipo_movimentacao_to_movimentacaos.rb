class AddTipoMovimentacaoToMovimentacaos < ActiveRecord::Migration[8.1]
  def change
    add_column :movimentacaos, :tipo_movimentacao, :string
    add_column :movimentacaos, :unidade, :string
  end
end
