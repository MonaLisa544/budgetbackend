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

ActiveRecord::Schema[7.0].define(version: 2026_02_27_213909) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "budgets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "budget_name", null: false
    t.integer "amount", null: false
    t.date "start_date", null: false
    t.date "due_date", null: false
    t.date "pay_due_date"
    t.string "status", default: "active", null: false
    t.text "description"
    t.boolean "delete_flag", default: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "wallet_id", null: false
    t.integer "used_amount", default: 0, null: false
    t.index ["category_id"], name: "index_budgets_on_category_id"
    t.index ["wallet_id"], name: "index_budgets_on_wallet_id"
  end

  create_table "categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "category_name", default: ""
    t.string "icon", default: ""
    t.string "icon_color", default: "#FF2196F3"
    t.string "transaction_type", default: "expense"
    t.boolean "delete_flag", default: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "families", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "delete_flag", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "family_name"
    t.string "password_digest"
    t.index ["family_name"], name: "index_families_on_family_name", unique: true
  end

  create_table "jwt_denylist", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti"
  end

  create_table "loans", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.string "loan_name", limit: 50, null: false
    t.string "loan_type", limit: 50
    t.decimal "original_amount", precision: 15, scale: 2, null: false
    t.decimal "interest_rate", precision: 5, scale: 2
    t.decimal "monthly_payment_amount", precision: 15, scale: 2
    t.integer "monthly_due_day"
    t.date "start_date", null: false
    t.date "due_date", null: false
    t.string "status", default: "active", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "total_amount_due", precision: 15, scale: 2, default: "0.0", null: false
    t.integer "paid_amount", default: 0, null: false
    t.index ["wallet_id"], name: "index_loans_on_wallet_id"
  end

  create_table "notifications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "body"
    t.string "notification_type"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "savings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "wallet_id", null: false
    t.string "saving_name", limit: 50, null: false
    t.integer "target_amount", null: false
    t.integer "paid_amount", default: 0, null: false
    t.date "start_date", null: false
    t.date "expected_date", null: false
    t.string "status", default: "active", null: false
    t.string "description"
    t.boolean "delete_flag", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wallet_id"], name: "index_savings_on_wallet_id"
  end

  create_table "transactions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "transaction_name", default: ""
    t.integer "transaction_amount", default: 0
    t.date "transaction_date"
    t.string "description", default: ""
    t.boolean "frequency", default: false
    t.boolean "delete_flag", default: false
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "wallet_id"
    t.string "source_type"
    t.bigint "source_id"
    t.index ["category_id"], name: "index_transactions_on_category_id"
    t.index ["source_type", "source_id"], name: "index_transactions_on_source"
    t.index ["user_id"], name: "index_transactions_on_user_id"
    t.index ["wallet_id"], name: "index_transactions_on_wallet_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "lastName"
    t.string "firstName"
    t.string "email"
    t.string "encrypted_password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.bigint "family_id"
    t.integer "role", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["family_id"], name: "index_users_on_family_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wallets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "balance", default: 0, null: false
    t.boolean "delete_flag", default: false
    t.string "owner_type"
    t.bigint "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_wallets_on_owner"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "budgets", "categories"
  add_foreign_key "budgets", "wallets"
  add_foreign_key "categories", "users"
  add_foreign_key "loans", "wallets"
  add_foreign_key "notifications", "users"
  add_foreign_key "savings", "wallets"
  add_foreign_key "transactions", "categories"
  add_foreign_key "transactions", "users"
  add_foreign_key "transactions", "wallets"
  add_foreign_key "users", "families"
end
