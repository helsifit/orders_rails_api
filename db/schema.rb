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

ActiveRecord::Schema[7.1].define(version: 2024_03_13_234302) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "line_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "product_variant_key", limit: 255, default: "unset", null: false
    t.integer "unit_amount", default: 0, null: false
    t.integer "quantity", default: 1, null: false
    t.index ["order_id"], name: "index_line_items_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "psp", limit: 255, default: "deferred", null: false
    t.string "country_code", limit: 255, default: "", null: false
    t.string "currency", limit: 3, default: "", null: false
    t.integer "total_amount", default: 0, null: false
    t.boolean "paid", default: false, null: false
    t.boolean "canceled", default: false, null: false
    t.string "email", limit: 255
    t.string "first_name", limit: 255, default: "", null: false
    t.string "last_name", limit: 255, default: "", null: false
    t.string "address1", limit: 255, default: "", null: false
    t.string "address2", limit: 255
    t.string "city", limit: 255, default: "", null: false
    t.string "zone", limit: 255
    t.string "postal_code", limit: 255, default: "", null: false
    t.uuid "token", null: false
    t.string "stripe_session_id", limit: 255
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["token"], name: "orders_token_index", unique: true
  end

  add_foreign_key "line_items", "orders", on_delete: :restrict
end
