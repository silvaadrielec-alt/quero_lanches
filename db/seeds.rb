Funcionario.find_or_create_by!(email: 'admin@admin.com') do |f|
  f.password = 'password123'
  f.password_confirmation = 'password123'
  f.admin = true
end
