class AddFieldsToFuncionarios < ActiveRecord::Migration[8.1]
  def change
    add_column :funcionarios, :telefone, :string
    add_column :funcionarios, :data_admissao, :date
    add_column :funcionarios, :data_demissao, :date
    add_column :funcionarios, :cpf, :string
  end
end
