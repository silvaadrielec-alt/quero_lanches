# db/seeds.rb
puts "Iniciando limpeza e criacao do admin..."

# Remove o antigo para garantir que não haja conflito de dados
Funcionario.where(email: 'admin@admin.com').destroy_all

# Cria o novo usando 'new' e 'save(validate: false)' para garantir o sucesso
admin = Funcionario.new(
  email: 'admin@admin.com',
  password: 'password123',
  password_confirmation: 'password123'
)
admin.admin = true # Define como administrador para passar no seu Controller
admin.save!(validate: false)

puts "SUCESSO: Usuario admin@admin.com criado com permissao total!"