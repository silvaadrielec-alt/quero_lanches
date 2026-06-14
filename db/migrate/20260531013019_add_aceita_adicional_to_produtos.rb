class AddAceitaAdicionalToProdutos < ActiveRecord::Migration[8.1]
  def change
    #  Adicionado o default: false para blindar o banco de dados
    add_column :produtos, :aceita_adicional, :boolean, default: false
  end
end