class CreateShopifyOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :shopify_orders, id: false do |t|
      t.bigint :id, primary_key: true
      t.string :app_id
      t.jsonb :billing_address1
      t.jsonb :billing_address2
      t.string :browser_ip
      t.boolean :buyer_accepts_marketing
      t.string :cancel_reason
      t.datetime :cancelled_at
      t.string :cart_token
      t.jsonb :client_details
      t.datetime :closed_at
      t.datetime :created_at
      t.string :currency
      t.jsonb :customer
      t.string :customer_locale
      t.jsonb :discount_applications, array: true
      t.jsonb :discount_codes, array: true
      t.string :email
      t.string :financial_status
      t.jsonb :fulfillments, array: true
      t.string :fulfillment_status
      t.string :landing_site
      t.jsonb :line_items, array: true
      t.string :location_id
      t.string :name
      t.string :note
      t.jsonb :note_attributes, array: true
      t.bigint :number
      t.bigint :order_number
      t.string :payment_gateway_names, array: true
      t.string :phone
      t.string :processed_at
      t.string :processing_method
      t.string :referring_site
      t.jsonb :refunds, array: true
      t.jsonb :shipping_address
      t.jsonb :shipping_lines, array: true
      t.string :source_name
      t.integer :subtotal_price
      t.string :tags
      t.jsonb :tax_lines, array: true
      t.boolean :taxes_included
      t.string :token
      t.string :total_discounts
      t.string :total_line_items_price
      t.string :total_price
      t.string :total_tax
      t.bigint :total_weight
      t.datetime :updated_at
      t.bigint :user_id
      t.string :order_status_url
    end
  end
end
