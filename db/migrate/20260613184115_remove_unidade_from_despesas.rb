class RemoveUnidadeFromDespesas < ActiveRecord::Migration[8.1]
  def change
    remove_column :despesas, :unidade, :string
  end
end
