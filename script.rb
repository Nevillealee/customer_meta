require 'dotenv/load'
Dotenv.load
require 'shopify_api'
require 'httparty'
require 'ruby-progressbar'
require 'active_record'
require 'recharge'
Dir['./models/*.rb'].each {|file| require file }

module CustomerAPI
  ACTIVE_CUSTOMER = []
  RECHARGE_ARRAY = []

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
    @customer_ids = InvalidCustomer.pluck(:shopify_customer_id)
    size = @customer_ids.size
    progressbar = ProgressBar.create(
    title: 'Progess',
    starting_at: 0,
    total: size,
    format: '%t: %p%%  |%B|')
    puts @customer_ids[0]

    @customer_ids.each do |current_id|
      current_meta = ShopifyAPI::Metafield.all(params:
        { resource: 'customers',
          resource_id: current_id,
          fields: 'namespace, key, value'
        })

      current_meta.each do |x|
        if x.namespace == 'subscriptions' && x.key =='customer_string'
          cust = InvalidCustomer.find_by(shopify_customer_id: current_id)
          cust.update(metafield_value: x.value)
        end
      end
      progressbar.increment
    end
  end

    # customer_count = HTTParty.get("https://api.rechargeapps.com/customers/count", :headers => my_header)
    # my_count = customer_count.parsed_response
    # num_customers = my_count['count']

  def self.save_recharge_customers
    # cust = ReCharge::Customer.list(:page => 1, :limit => 1)
    # puts cust[0].id
    init_recharge
    RECHARGE_ARRAY.each do |cust|
      puts "saving #{cust.id}"
      RechargeCustomer.create(
        id: cust.id,
        customer_hash: cust.hash,
        shopify_customer_id: cust.shopify_customer_id,
        email: cust.email,
        created_at: cust.created_at,
        updated_at: cust.updated_at,
        first_name: cust.first_name,
        last_name: cust.last_name,
        billing_address1: cust.billing_address1,
        billing_address2: cust.billing_address2,
        billing_zip: cust.billing_zip,
        billing_city: cust.billing_city,
        billing_company: cust.billing_company,
        billing_province: cust.billing_province,
        billing_country: cust.billing_country,
        billing_phone: cust.billing_phone,
        processor_type: cust.processor_type,
        status: cust.status
      )
    end
  end

  private
  def self.init_recharge
    ReCharge.api_key ="#{ENV['RECHARGE_ELLIE_TOKEN']}"
    customer_count = Recharge::Customer.count
    nb_pages = (customer_count / 250.0).ceil

    1.upto(nb_pages) do |current_page| # throttling conditon
      customers = ReCharge::Customer.list(:page => current_page, :limit => 250)
      RECHARGE_ARRAY.push(customers)
      p "recharge customer set #{current_page} loaded, sleeping 3"
      sleep 3
    end
    p 'recharge customers initialized'
    RECHARGE_ARRAY.flatten!
  end
end
