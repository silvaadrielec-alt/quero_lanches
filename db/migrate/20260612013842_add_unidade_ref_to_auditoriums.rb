class AddUnidadeRefToAuditoriums < ActiveRecord::Migration[8.1]
  def change
    add_reference :auditoria, :unidade, foreign_key: true
  end
end
