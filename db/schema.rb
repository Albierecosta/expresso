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

ActiveRecord::Schema[8.0].define(version: 2026_06_05_180729) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "street", null: false
    t.string "number"
    t.string "complement"
    t.string "neighborhood"
    t.string "city", null: false
    t.string "state", limit: 2, null: false
    t.string "zipcode", null: false
    t.string "addressable_type", null: false
    t.bigint "addressable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable", unique: true
  end

  create_table "clients", force: :cascade do |t|
    t.string "name", null: false
    t.string "document"
    t.string "email"
    t.string "phone"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_clients_on_created_by_id"
    t.index ["updated_by_id"], name: "index_clients_on_updated_by_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "legal_name"
    t.string "cnpj", null: false
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cnpj"], name: "index_companies_on_cnpj", unique: true
  end

  create_table "freights", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.bigint "recipient_id", null: false
    t.bigint "driver_id"
    t.string "code", null: false
    t.string "public_token", null: false
    t.string "status", default: "pending", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "order_number"
    t.text "notes"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_freights_on_client_id"
    t.index ["code"], name: "index_freights_on_code", unique: true
    t.index ["created_by_id"], name: "index_freights_on_created_by_id"
    t.index ["driver_id"], name: "index_freights_on_driver_id"
    t.index ["public_token"], name: "index_freights_on_public_token", unique: true
    t.index ["recipient_id"], name: "index_freights_on_recipient_id"
    t.index ["status"], name: "index_freights_on_status"
    t.index ["updated_by_id"], name: "index_freights_on_updated_by_id"
  end

  create_table "recipients", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.string "name", null: false
    t.string "document"
    t.string "email"
    t.string "phone"
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_recipients_on_client_id"
    t.index ["created_by_id"], name: "index_recipients_on_created_by_id"
    t.index ["updated_by_id"], name: "index_recipients_on_updated_by_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "role", default: "operator", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "clients", "users", column: "created_by_id"
  add_foreign_key "clients", "users", column: "updated_by_id"
  add_foreign_key "freights", "clients"
  add_foreign_key "freights", "recipients"
  add_foreign_key "freights", "users", column: "created_by_id"
  add_foreign_key "freights", "users", column: "driver_id"
  add_foreign_key "freights", "users", column: "updated_by_id"
  add_foreign_key "recipients", "clients"
  add_foreign_key "recipients", "users", column: "created_by_id"
  add_foreign_key "recipients", "users", column: "updated_by_id"
end
