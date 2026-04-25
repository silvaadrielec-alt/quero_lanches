class AddAdminToFuncionarios < ActiveRecord::Migration[8.1]
  def change
    add_column :funcionarios, :admin, :boolean, default: false
  end
end
