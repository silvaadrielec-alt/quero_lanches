json.extract! despesa, :id, :descricao, :categoria, :valor, :data_pagamento, :pago, :created_at, :updated_at
json.url despesa_url(despesa, format: :json)
