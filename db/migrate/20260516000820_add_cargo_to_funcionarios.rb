class AddCargoToFuncionarios < ActiveRecord::Migration[8.1]
  def change
    add_column :funcionarios, :cargo, :string
  end
end
