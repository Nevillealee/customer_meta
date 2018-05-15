class CreateRechargeSubscription < ActiveRecord::Migration[5.2]
  def change
    create_table :recharge_subscriptions, id: false do |t|
      t.bigint :id, primary_key: true
      t.string :address_id
      t.string :customer_id, index: true
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :next_charge_scheduled_at
      t.datetime :cancelled_at
      t.string :product_title
      t.integer :price
      t.integer :quantity
      t.string :status
      t.string :shopify_variant_id
      t.string :sku
      t.string :order_interval_frequency
      t.integer :order_day_of_month
      t.integer :order_day_of_week
      t.jsonb :properties, array: true
      t.integer :expire_after_specfic_number_of_charges
    end
  end
end
