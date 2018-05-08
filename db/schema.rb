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

ActiveRecord::Schema.define(version: 2018_05_07_233417) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "customer_metas", force: :cascade do |t|
    t.string "first"
    t.string "last"
    t.string "email"
    t.string "customer_string"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string "accepts_marketing"
    t.jsonb "addresses", array: true
    t.string "default_address"
    t.string "email"
    t.string "first_name"
    t.string "last_name"
    t.string "last_order_id"
    t.string "metafield"
    t.string "multipass_identifier"
    t.string "note"
    t.integer "orders_count"
    t.string "phone"
    t.string "state"
    t.string "tags", array: true
    t.boolean "tax_exempt"
    t.string "total_spent"
    t.boolean "verified_email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "metas", force: :cascade do |t|
    t.string "first"
    t.string "last"
    t.string "email"
    t.string "customer_string"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
