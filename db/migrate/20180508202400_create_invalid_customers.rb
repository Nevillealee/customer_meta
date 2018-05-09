class CreateInvalidCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :invalid_customers do |t|
      t.string :subscription_id
      t.string :shopify_customer_id
      t.string :email
      t.string :metafield_value
      t.boolean :process, default: false
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
