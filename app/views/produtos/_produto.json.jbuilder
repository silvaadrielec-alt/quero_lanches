json.extract! produto, :id, :nome, :valor_unitario, :estoque, :created_at, :updated_at
json.url produto_url(produto, format: :json)
