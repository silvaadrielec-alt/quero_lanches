class AddUnidadeMedidaUsoToComposicoes < ActiveRecord::Migration[8.1]
  def change
    add_column :composicaos, :unidade_medida_uso, :string
  end
end
