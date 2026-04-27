# Limpa usuários antigos para não duplicar se você rodar o comando duas vezes
User.destroy_all 

# Cria o seu usuário administrador
User.create!(
  email: 'admin@admin.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: 'admin'
)

puts "Usuário admin criado com sucesso!"
