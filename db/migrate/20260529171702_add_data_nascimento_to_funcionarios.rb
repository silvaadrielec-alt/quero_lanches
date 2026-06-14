class AddDataNascimentoToFuncionarios < ActiveRecord::Migration[8.1]
  def change
    add_column :funcionarios, :data_nascimento, :date
  end
end
