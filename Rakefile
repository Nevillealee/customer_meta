require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require 'dotenv'
Dotenv.load
require 'sinatra'
set :database_file, "config/database.yml"
Dir['./models/*.rb'].each {|file| require file }
require_relative 'script.rb'

namespace :customer do
  desc 'pull active customers down from shopify'
  task :save_actives do
    CustomerAPI.save_customers
  end

  desc 'pull down all customer metafields'
  task :pull_meta do
    CustomerAPI.pull_metafields
  end
end
