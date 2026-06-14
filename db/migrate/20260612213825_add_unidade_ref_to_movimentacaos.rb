class AddUnidadeRefToMovimentacaos < ActiveRecord::Migration[8.1]
  def change
    # Removemos o null: false para que a migração aceite os dados antigos
    add_reference :movimentacaos, :unidade, foreign_key: true
  end
end