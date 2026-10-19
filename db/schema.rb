# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_04_160018) do
  create_table "auditoria", force: :cascade do |t|
    t.string "acao"
    t.datetime "created_at", null: false
    t.text "descricao"
    t.integer "funcionario_id", null: false
    t.integer "registro_id"
    t.string "tabela_afetada"
    t.integer "unidade_id"
    t.datetime "updated_at", null: false
    t.decimal "valor_anterior"
    t.decimal "valor_novo"
    t.index ["funcionario_id"], name: "index_auditoria_on_funcionario_id"
    t.index ["unidade_id"], name: "index_auditoria_on_unidade_id"
  end

  create_table "clientes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nome"
    t.datetime "updated_at", null: false
  end

  create_table "composicaos", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "insumo_id"
    t.integer "produto_id"
    t.decimal "quantidade"
    t.string "unidade_medida_uso"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "despesas", force: :cascade do |t|
    t.string "categoria"
    t.datetime "created_at", null: false
    t.datetime "data_pagamento"
    t.datetime "data_vencimento"
    t.string "descricao"
    t.integer "funcionario_id", null: false
    t.boolean "pago"
    t.string "turno"
    t.integer "unidade_id"
    t.datetime "updated_at", null: false
    t.decimal "valor"
    t.index ["funcionario_id"], name: "index_despesas_on_funcionario_id"
    t.index ["unidade_id"], name: "index_despesas_on_unidade_id"
  end

  create_table "funcionarios", force: :cascade do |t|
    t.boolean "admin", default: false
    t.string "cargo"
    t.string "codigo_autorizacao"
    t.string "cpf"
    t.datetime "created_at", null: false
    t.date "data_admissao"
    t.date "data_demissao"
    t.date "data_nascimento"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "nome"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role"
    t.string "telefone"
    t.string "turno"
    t.integer "unidade_id"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_funcionarios_on_email", unique: true
    t.index ["reset_password_token"], name: "index_funcionarios_on_reset_password_token", unique: true
    t.index ["unidade_id"], name: "index_funcionarios_on_unidade_id"
  end

  create_table "insumos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "estoque_centro", precision: 10, scale: 3, default: "0.0"
    t.decimal "estoque_minimo"
    t.decimal "estoque_pavilhao_antigo", precision: 10, scale: 3, default: "0.0"
    t.decimal "estoque_pavilhao_novo", precision: 10, scale: 3, default: "0.0"
    t.decimal "limite_centro"
    t.decimal "limite_pavilhao_antigo"
    t.decimal "limite_pavilhao_novo"
    t.decimal "media_unidades_kg", precision: 10, scale: 3, default: "0.0"
    t.string "nome"
    t.decimal "preco_custo", precision: 10, scale: 2, default: "0.0"
    t.decimal "preco_venda", precision: 10, scale: 2, default: "0.0"
    t.string "unidade_medida", default: "un"
    t.datetime "updated_at", null: false
  end

  create_table "item_pedido_adicionals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "insumo_id", null: false
    t.integer "item_pedido_id", null: false
    t.decimal "preco_unitario"
    t.float "quantidade"
    t.datetime "updated_at", null: false
    t.index ["insumo_id"], name: "index_item_pedido_adicionals_on_insumo_id"
    t.index ["item_pedido_id"], name: "index_item_pedido_adicionals_on_item_pedido_id"
  end

  create_table "item_pedidos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "observacao"
    t.integer "pedido_id", null: false
    t.decimal "preco_unitario", precision: 10, scale: 2, default: "0.0"
    t.integer "produto_id", null: false
    t.decimal "quantidade"
    t.string "tamanho"
    t.datetime "updated_at", null: false
    t.index ["pedido_id"], name: "index_item_pedidos_on_pedido_id"
    t.index ["produto_id"], name: "index_item_pedidos_on_produto_id"
  end

  create_table "movimentacaos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "destino"
    t.integer "funcionario_id", null: false
    t.integer "insumo_id"
    t.integer "item_pedido_id"
    t.string "origem"
    t.integer "produto_id"
    t.decimal "quantidade", precision: 10, scale: 3
    t.string "tipo_movimentacao"
    t.integer "unidade_id"
    t.string "unidade_medida"
    t.datetime "updated_at", null: false
    t.decimal "valor_custo", precision: 10, scale: 2, default: "0.0"
    t.decimal "valor_receita", precision: 10, scale: 2, default: "0.0"
    t.index ["funcionario_id"], name: "index_movimentacaos_on_funcionario_id"
    t.index ["insumo_id"], name: "index_movimentacaos_on_insumo_id"
    t.index ["produto_id"], name: "index_movimentacaos_on_produto_id"
    t.index ["unidade_id"], name: "index_movimentacaos_on_unidade_id"
  end

  create_table "notificacaos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "lida", default: false
    t.text "mensagem"
    t.string "tipo"
    t.string "titulo"
    t.datetime "updated_at", null: false
  end

  create_table "pedidos", force: :cascade do |t|
    t.integer "cliente_id"
    t.string "cliente_nome"
    t.datetime "created_at", null: false
    t.integer "funcionario_id", null: false
    t.string "identificador"
    t.string "ingredientes_removidos"
    t.text "observacao"
    t.decimal "pago_cartao_credito"
    t.decimal "pago_cartao_debito"
    t.decimal "pago_dinheiro"
    t.decimal "pago_pix"
    t.string "tamanho"
    t.string "turno"
    t.integer "unidade_id"
    t.datetime "updated_at", null: false
    t.decimal "valor_total"
    t.index ["cliente_id"], name: "index_pedidos_on_cliente_id"
    t.index ["funcionario_id"], name: "index_pedidos_on_funcionario_id"
    t.index ["unidade_id"], name: "index_pedidos_on_unidade_id"
  end

  create_table "produtos", force: :cascade do |t|
    t.boolean "aceita_adicional", default: false
    t.string "categoria"
    t.string "codigo"
    t.datetime "created_at", null: false
    t.decimal "estoque", precision: 10, scale: 3, default: "0.0"
    t.decimal "estoque_centro", precision: 10, scale: 3, default: "0.0"
    t.boolean "estoque_controlado", default: true
    t.integer "estoque_minimo"
    t.decimal "estoque_pavilhao_antigo", precision: 10, scale: 3, default: "0.0"
    t.decimal "estoque_pavilhao_novo", precision: 10, scale: 3, default: "0.0"
    t.boolean "insumo"
    t.integer "limite_centro"
    t.integer "limite_pavilhao_antigo"
    t.integer "limite_pavilhao_novo"
    t.decimal "media_unidades_kg", precision: 10, scale: 2, default: "1.0"
    t.string "nome"
    t.decimal "preco_venda"
    t.string "unidade_medida"
    t.datetime "updated_at", null: false
    t.decimal "valor_unitario"
  end

  create_table "referencia_rendimentos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "fator"
    t.string "insumo_nome"
    t.string "unidade_medida"
    t.datetime "updated_at", null: false
  end

  create_table "unidades", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nome"
    t.datetime "updated_at", null: false
  end

  create_table "variacao_produtos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "preco_venda"
    t.integer "produto_id", null: false
    t.string "tamanho"
    t.datetime "updated_at", null: false
    t.index ["produto_id"], name: "index_variacao_produtos_on_produto_id"
  end

  add_foreign_key "auditoria", "funcionarios"
  add_foreign_key "auditoria", "unidades"
  add_foreign_key "despesas", "funcionarios"
  add_foreign_key "funcionarios", "unidades"
  add_foreign_key "item_pedido_adicionals", "insumos"
  add_foreign_key "item_pedido_adicionals", "item_pedidos"
  add_foreign_key "item_pedidos", "pedidos"
  add_foreign_key "item_pedidos", "produtos"
  add_foreign_key "movimentacaos", "funcionarios"
  add_foreign_key "movimentacaos", "insumos"
  add_foreign_key "movimentacaos", "produtos"
  add_foreign_key "movimentacaos", "unidades"
  add_foreign_key "pedidos", "clientes"
  add_foreign_key "pedidos", "funcionarios"
  add_foreign_key "pedidos", "unidades"
  add_foreign_key "variacao_produtos", "produtos"
end
