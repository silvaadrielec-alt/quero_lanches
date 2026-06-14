class AddUnidadeIdToDespesas < ActiveRecord::Migration[8.1]
  def change
    add_column :despesas, :unidade_id, :integer
    add_index :despesas, :unidade_id
  end
end
