class AddCodigoAutorizacaoToFuncionarios < ActiveRecord::Migration[8.1]
  def change
    add_column :funcionarios, :codigo_autorizacao, :string
  end
end
