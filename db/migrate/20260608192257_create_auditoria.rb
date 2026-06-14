class CreateAuditoria < ActiveRecord::Migration[8.1]
  def change
    create_table :auditoria do |t|
      t.references :funcionario, null: false, foreign_key: true
      t.string :unidade
      t.string :tabela_afetada
      t.integer :registro_id
      t.string :acao
      t.text :descricao
      t.decimal :valor_anterior
      t.decimal :valor_novo

      t.timestamps
    end
  end
end
