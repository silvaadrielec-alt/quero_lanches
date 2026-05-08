class AddContextToDespesas < ActiveRecord::Migration[8.1]
  def change
    add_column :despesas, :unidade, :string
    add_column :despesas, :turno, :string
    add_reference :despesas, :funcionario, null: false, foreign_key: true
  end
end
