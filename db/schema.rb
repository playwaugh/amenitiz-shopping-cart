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

ActiveRecord::Schema[7.2].define(version: 2025_03_24_173747) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "discount_rules", force: :cascade do |t|
    t.string "name"
    t.string "rule_type"
    t.integer "min_quantity"
    t.integer "free_quantity"
    t.decimal "new_unit_price"
    t.decimal "discount_percentage"
    t.bigint "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_discount_rules_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_products_on_code", unique: true
  end

  add_foreign_key "discount_rules", "products"
end
