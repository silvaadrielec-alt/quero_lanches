class AddUnidadeRefToFuncionarios < ActiveRecord::Migration[8.1]
  def change
    add_reference :funcionarios, :unidade, foreign_key: true
  end
end
