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

ActiveRecord::Schema.define(version: 2018_05_30_232655) do

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
    t.jsonb "addresses"
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
    t.string "tags"
    t.boolean "tax_exempt"
    t.string "total_spent"
    t.boolean "verified_email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invalid_customers", force: :cascade do |t|
    t.string "subscription_id"
    t.string "shopify_customer_id"
    t.string "email"
    t.string "metafield_value"
    t.boolean "process", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recharge_customers", force: :cascade do |t|
    t.string "customer_hash"
    t.string "shopify_customer_id"
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "first_name"
    t.string "last_name"
    t.string "billing_address1"
    t.string "billing_address2"
    t.string "billing_zip"
    t.string "billing_city"
    t.string "billing_company"
    t.string "billing_province"
    t.string "billing_country"
    t.string "billing_phone"
    t.string "processor_type"
    t.string "status"
    t.index ["shopify_customer_id"], name: "index_recharge_customers_on_shopify_customer_id"
  end

  create_table "recharge_subscriptions", force: :cascade do |t|
    t.string "address_id"
    t.string "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "next_charge_scheduled_at"
    t.datetime "cancelled_at"
    t.string "product_title"
    t.integer "price"
    t.integer "quantity"
    t.string "status"
    t.string "shopify_variant_id"
    t.string "sku"
    t.string "order_interval_frequency"
    t.integer "order_day_of_month"
    t.integer "order_day_of_week"
    t.jsonb "properties", array: true
    t.integer "expire_after_specfic_number_of_charges"
    t.index ["customer_id"], name: "index_recharge_subscriptions_on_customer_id"
  end

  create_table "shopify_orders", force: :cascade do |t|
    t.string "app_id"
    t.jsonb "billing_address1"
    t.jsonb "billing_address2"
    t.string "browser_ip"
    t.boolean "buyer_accepts_marketing"
    t.string "cancel_reason"
    t.datetime "cancelled_at"
    t.string "cart_token"
    t.jsonb "client_details"
    t.datetime "closed_at"
    t.datetime "created_at"
    t.string "currency"
    t.jsonb "customer"
    t.string "customer_locale"
    t.jsonb "discount_applications", array: true
    t.jsonb "discount_codes", array: true
    t.string "email"
    t.string "financial_status"
    t.jsonb "fulfillments", array: true
    t.string "fulfillment_status"
    t.string "landing_site"
    t.string "location_id"
    t.string "name"
    t.string "note"
    t.jsonb "note_attributes", array: true
    t.bigint "number"
    t.bigint "order_number"
    t.string "payment_gateway_names", array: true
    t.string "phone"
    t.string "processed_at"
    t.string "processing_method"
    t.string "referring_site"
    t.jsonb "refunds", array: true
    t.jsonb "shipping_address"
    t.jsonb "shipping_lines", array: true
    t.string "source_name"
    t.integer "subtotal_price"
    t.string "tags"
    t.jsonb "tax_lines", array: true
    t.boolean "taxes_included"
    t.string "token"
    t.string "total_discounts"
    t.string "total_line_items_price"
    t.string "total_price"
    t.string "total_tax"
    t.bigint "total_weight"
    t.datetime "updated_at"
    t.bigint "user_id"
    t.string "order_status_url"
    t.jsonb "line_items"
  end

end
