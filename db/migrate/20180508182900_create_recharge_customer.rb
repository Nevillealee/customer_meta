class CreateRechargeCustomer < ActiveRecord::Migration[5.2]
  def up
    create_table :recharge_customers, id: false do |t|
      t.bigint :id, primary_key: true
      t.string :hash
      t.string :shopify_customer_id
      t.string :email
      t.datetime :created_at
      t.datetime :updated_at
      t.string :first_name
      t.string :last_name
      t.string :billing_address1
      t.string :billing_address2
      t.string :billing_zip
      t.string :billing_city
      t.string :billing_company
      t.string :billing_province
      t.string :billing_country
      t.string :billing_phone
      t.string :processor_type
      t.string :status
    end
    add_index :recharge_customers, :shopify_customer_id
  end

  def down
    remove_index :recharge_customers, :shopify_customer_id
    drop_table :recharge_customers
  end
end
