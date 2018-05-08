class CreateCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :customers, id: false do |t|
      t.bigint :id, primary_key: true
      t.string :accepts_marketing
      t.jsonb :addresses
      t.string :default_address
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :last_order_id
      t.string :metafield
      t.string :multipass_identifier
      t.string :note
      t.integer :orders_count
      t.string :phone
      t.string :state
      t.string :tags
      t.boolean :tax_exempt
      t.string :total_spent
      t.boolean :verified_email
      t.datetime :created_at
      t.datetime :updated_at
    end
  end
end
