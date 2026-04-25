class AddUnidadeToFuncionarios < ActiveRecord::Migration[8.1]
  def change
    add_column :funcionarios, :unidade, :string
  end
end
