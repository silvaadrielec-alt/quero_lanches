json.extract! movimentacao, :id, :produto_id, :origem, :destino, :quantidade, :funcionario_id, :created_at, :updated_at
json.url movimentacao_url(movimentacao, format: :json)
