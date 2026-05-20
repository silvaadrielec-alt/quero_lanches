class ChangeDespesasDatesToDatetime < ActiveRecord::Migration[7.1]
  def change
    change_column :despesas, :data_pagamento, :datetime
    change_column :despesas, :data_vencimento, :datetime
  end
end