# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180328130719) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "product_shopify_id"
    t.integer "shop_id"
    t.integer "promotion_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products_promotions", force: :cascade do |t|
    t.integer "product_id"
    t.integer "promotion_id"
  end

  create_table "promotion_details", force: :cascade do |t|
    t.integer "promotion_id"
    t.string "content"
    t.decimal "qty"
    t.decimal "value"
    t.string "discount_method"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "promotions", force: :cascade do |t|
    t.string "shop_id"
    t.string "promotion_name"
    t.integer "promotion_type"
    t.string "promotion_details"
    t.string "qty_option"
    t.string "messages"
    t.string "customer_option"
    t.integer "status"
    t.date "valid_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shop_backups", force: :cascade do |t|
    t.integer "shop_id"
    t.string "layout_name"
    t.string "backup_content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shops", force: :cascade do |t|
    t.string "shopify_domain", null: false
    t.string "shopify_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "domain_url"
    t.index ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true
  end

end
