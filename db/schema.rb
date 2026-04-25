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

ActiveRecord::Schema[8.1].define(version: 2026_04_25_164106) do
  create_table "clientes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nome"
    t.datetime "updated_at", null: false
  end

  create_table "funcionarios", force: :cascade do |t|
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "nome"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "unidade"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_funcionarios_on_email", unique: true
    t.index ["reset_password_token"], name: "index_funcionarios_on_reset_password_token", unique: true
  end

  create_table "movimentacaos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "destino"
    t.integer "funcionario_id", null: false
    t.string "origem"
    t.integer "produto_id", null: false
    t.integer "quantidade"
    t.datetime "updated_at", null: false
    t.index ["funcionario_id"], name: "index_movimentacaos_on_funcionario_id"
    t.index ["produto_id"], name: "index_movimentacaos_on_produto_id"
  end

  create_table "pedidos", force: :cascade do |t|
    t.integer "cliente_id"
    t.string "cliente_nome"
    t.datetime "created_at", null: false
    t.integer "funcionario_id", null: false
    t.string "identificador"
    t.integer "produto_id", null: false
    t.integer "quantidade"
    t.string "unidade"
    t.datetime "updated_at", null: false
    t.decimal "valor_total"
    t.index ["cliente_id"], name: "index_pedidos_on_cliente_id"
    t.index ["funcionario_id"], name: "index_pedidos_on_funcionario_id"
    t.index ["produto_id"], name: "index_pedidos_on_produto_id"
  end

  create_table "produtos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "estoque"
    t.integer "estoque_centro"
    t.integer "estoque_pavilhao_antigo"
    t.integer "estoque_pavilhao_novo"
    t.string "nome"
    t.datetime "updated_at", null: false
    t.decimal "valor_unitario"
  end

  add_foreign_key "movimentacaos", "funcionarios"
  add_foreign_key "movimentacaos", "produtos"
  add_foreign_key "pedidos", "clientes"
  add_foreign_key "pedidos", "funcionarios"
  add_foreign_key "pedidos", "produtos"
end
