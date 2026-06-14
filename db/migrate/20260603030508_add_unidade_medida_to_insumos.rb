class AddUnidadeMedidaToInsumos < ActiveRecord::Migration[8.1]
  def change
    # Adiciona a coluna unidade_medida na tabela insumos com padrão 'un'
    add_column :insumos, :unidade_medida, :string, default: "un"
  end
end
