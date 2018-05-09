require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require 'dotenv'
Dotenv.load
require 'sinatra'
require 'recharge'
set :database_file, "config/database.yml"
Dir['./models/*.rb'].each {|file| require file }
require_relative 'script.rb'

namespace :customer do
  desc 'pull active customers down from shopify'
  task :save_actives do
    CustomerAPI.save_customers
  end

  desc 'pull down all customer metafields'
  task :pull_meta do\
    CustomerAPI.pull_metafields
  end

  desc 'pull down all recharge customer'
  task :pull_recharge_customers do\
    CustomerAPI.save_recharge_customers
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
