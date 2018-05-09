class ChangeHashColumnName < ActiveRecord::Migration[5.2]
  def change
    rename_column :recharge_customers, :hash, :customer_hash
  end
end
