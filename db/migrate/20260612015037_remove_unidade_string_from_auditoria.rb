class RemoveUnidadeStringFromAuditoria < ActiveRecord::Migration[8.1]
  def change
    remove_column :auditoria, :unidade, :string
  end
end
