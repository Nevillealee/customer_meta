require 'dotenv/load'
require 'shopify_api'
require 'httparty'
require 'ruby-progressbar'
require 'active_record'
Dir['./models/*.rb'].each {|file| require file }

module CustomerAPI
  ACTIVE_CUSTOMER = []

  def self.shopify_api_throttle
    ShopifyAPI::Base.site =
      "https://#{ENV['ACTIVE_API_KEY']}:#{ENV['ACTIVE_API_PW']}@#{ENV['ACTIVE_SHOP']}.myshopify.com/admin"
      return if ShopifyAPI.credit_left > 5
      sleep 10
  end

  def self.init_actives
    ShopifyAPI::Base.site =
      "https://#{ENV['ACTIVE_API_KEY']}:#{ENV['ACTIVE_API_PW']}@#{ENV['ACTIVE_SHOP']}.myshopify.com/admin"
    active_customer_count = ShopifyAPI::Customer.count
    nb_pages = (active_customer_count / 250.0).ceil

    puts active_customer_count

    1.upto(nb_pages) do |page|
      ellie_active_url =
        "https://#{ENV['ACTIVE_API_KEY']}:#{ENV['ACTIVE_API_PW']}@#{ENV['ACTIVE_SHOP']}.myshopify.com/admin/customers.json?limit=250&page=#{page}"
      @parsed_response = HTTParty.get(ellie_active_url)

      ACTIVE_CUSTOMER.push(@parsed_response['customers'])
      p "active customers set #{page} loaded, sleeping 3"
      sleep 3
    end
    p 'active customers initialized'

    ACTIVE_CUSTOMER.flatten!
  end

  def self.save_customers
    init_actives
    size = ACTIVE_CUSTOMER.size
    progressbar = ProgressBar.create(
    title: 'Progess',
    starting_at: 0,
    total: size,
    format: '%t: %p%%  |%B|')

    ACTIVE_CUSTOMER.each do |current|
      begin
        Customer.create(
        id: current['id'],
        accepts_marketing: current['accepts_marketing'],
        addresses: current['addresses'],
        default_address: current['default_address'],
        email: current['email'],
        first_name: current['first_name'],
        last_name: current['last_name'],
        last_order_id: current['last_order_id'],
        metafield: current['metafield'],
        multipass_identifier: current['multipass_identifier'],
        note: current['note'],
        orders_count: current['orders_count'],
        phone: current['phone'],
        state: current['state'],
        tags: current['tags'],
        tax_exempt: current['tax_exempt'],
        total_spent: current['total_spent'],
        verified_email: current['verified_email'],
        created_at: current['created_at'],
        updated_at: current['updated_at']
      )
      rescue
        puts "error with #{current['first_name']} #{current['last_name']}"
        next
      end
      progressbar.increment
    end
    p 'customers saved to db'
  end

  def self.pull_metafields
    ShopifyAPI::Base.site =
    "https://#{ENV['ACTIVE_API_KEY']}:#{ENV['ACTIVE_API_PW']}@#{ENV['ACTIVE_SHOP']}.myshopify.com/admin"
    @customer_ids = Customer.pluck(:id, :first_name, :last_name, :email)
    size = @customer_ids.size
    progressbar = ProgressBar.create(
    title: 'Progess',
    starting_at: 0,
    total: size,
    format: '%t: %p%%  |%B|')

    puts size
    @customer_ids.each do |cust|
      current_meta = ShopifyAPI::Metafield.all(params:
        { resource: 'customers',
          resource_id: cust[0],
          fields: 'namespace, key, value, id, value_type'
        })

      current_meta.each do |x|
        if x.namespace == 'subscriptions' && x.key =='customer_string'
          cust = CustomerMeta.create(
            first: cust[1],
            last: cust[2],
            email: cust[3],
            customer_string: x.value
          )
        end
      end
      progressbar.increment
    end
  end


end
