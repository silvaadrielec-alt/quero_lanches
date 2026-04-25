json.extract! funcionario, :id, :nome, :created_at, :updated_at
json.url funcionario_url(funcionario, format: :json)
