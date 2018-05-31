class ChangeShopifyOrderColumn < ActiveRecord::Migration[5.2]
  def change
    remove_column :shopify_orders, :line_items
    add_column :shopify_orders, :line_items, :jsonb
  end
end
