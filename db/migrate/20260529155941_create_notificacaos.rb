class CreateNotificacaos < ActiveRecord::Migration[8.1]
  def change
    create_table :notificacaos do |t|
      t.string :titulo
      t.text :mensagem
      t.string :tipo
      t.boolean :lida, default: false # 🌟 Alterado aqui!

      t.timestamps
    end
  end
end
