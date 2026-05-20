class AddDataVencimentoToDespesas < ActiveRecord::Migration[8.1]
  def change
    add_column :despesas, :data_vencimento, :date
  end
end
