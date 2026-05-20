class AddTurnoToFuncionarios < ActiveRecord::Migration[8.1]
  def change
    add_column :funcionarios, :turno, :string
  end
end
