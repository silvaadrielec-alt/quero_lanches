class AddRoleToFuncionarios < ActiveRecord::Migration[8.1]
  def change
    add_column :funcionarios, :role, :string
  end
end
