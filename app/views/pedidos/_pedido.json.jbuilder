json.extract! pedido, :id, :produto_id, :cliente_id, :funcionario_id, :quantidade, :valor_total, :created_at, :updated_at
json.url pedido_url(pedido, format: :json)
