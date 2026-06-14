class AddInsumoToMovimentacoes < ActiveRecord::Migration[8.1]
  def change
    # 1. Altera a tabela legítima mapeada no schema
    # Adiciona o campo de insumos permitindo nulos para movimentações de produtos normais
    add_reference :movimentacaos, :insumo, null: true, foreign_key: true

    # 2. Afrouxa a restrição antiga do produto_id para permitir nulos quando for um insumo
    change_column_null :movimentacaos, :produto_id, true
  end
end