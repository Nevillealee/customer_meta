require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require 'dotenv'
Dotenv.load
require 'sinatra'
require 'recharge'
set :database_file, "config/database.yml"
Dir['./models/*.rb'].each {|file| require file }
require_relative 'script.rb'

namespace :shopify do
  desc 'tags recurring orders with "3month_nocharge"'
  task :tag_orders do
    CustomerAPI.tag_orders
  end

  desc 'pull shopify customers'
  task :save_customers do
    ActiveRecord::Base.connection.execute("TRUNCATE customers;") if Customer.exists?
    CustomerAPI.save_shopify_customers
  end

  desc 'pull customer metafields'
  task :pull_metas do
    CustomerAPI.pull_metafields
  end

  desc 'pull shopify orders'
  task :save_orders do
    ActiveRecord::Base.connection.execute("TRUNCATE shopify_orders;") if ShopifyOrder.exists?
    CustomerAPI.save_shopify_orders
  end
end

namespace :recharge do
  desc 'pull recharge customers'
  task :save_customers do
    ActiveRecord::Base.connection.execute("TRUNCATE recharge_customers;")
    CustomerAPI.save_recharge_customers
  end

  desc 'pull recharge subs'
  task :save_subs do
    ActiveRecord::Base.connection.execute("TRUNCATE recharge_subscriptions;") if RechargeSubscription.exists?
    CustomerAPI.save_recharge_subscriptions
  end
end

namespace :csv do
  desc 'import active subscriber csv into pg'
  task :import do
    ActiveRecord::Base.connection.execute("TRUNCATE invalid_customers;")
    puts "invalid_customers table truncated.."
    ActiveRecord::Base.connection.execute("ALTER SEQUENCE invalid_customers_id_seq RESTART;")
    puts "invalid_customers pk_seq restarted.."
    ActiveRecord::Base.connection.execute(
      "COPY invalid_customers(subscription_id, shopify_customer_id, email)
      FROM '/home/neville/Desktop/fam_brands/subscribers_active.csv' DELIMITER ',' CSV HEADER;"
    )
    puts "csv imported!"
  end
end
