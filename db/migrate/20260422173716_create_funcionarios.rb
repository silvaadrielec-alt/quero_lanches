class CreateFuncionarios < ActiveRecord::Migration[8.1]
  def change
    create_table :funcionarios do |t|
      t.string :nome

      t.timestamps
    end
  end
end
