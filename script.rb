require 'dotenv/load'
Dotenv.load
require 'shopify_api'
require 'httparty'
require 'ruby-progressbar'
require 'active_record'
require 'recharge'
Dir['./models/*.rb'].each {|file| require file }

module CustomerAPI
  SHOPIFY_CUSTOMERS = []
  SHOPIFY_ORDERS = []
  RECHARGE_CUSTOMERS = []
  RECHARGE_SUBS = []
  my_token = ENV['RECHARGE_ELLIE_TOKEN']
  @my_header = {
    "X-Recharge-Access-Token" => my_token
  }

  def self.get_untagged_orders
    order_ids = []
    obj_array = ShopifyOrder.all
    obj_array.each do |obj|
      obj.line_items.each do |x|
        if x["properties"] != []
          x["properties"].each do |key|
            if key["name"] == 'charge_interval_frequency' &&
               key["value"] == '3'
               order_ids.push(obj.id)
            end
          end
        end
      end
    end
    return order_ids
  end

  def self.tag_orders
    order_ids = get_untagged_orders
    puts "#{order_ids.size} orders to tag"
    puts order_ids.inspect

    order_ids.each do |my_id|
    puts "We are working on customer #{my_id}"
    ShopifyAPI::Base.site =
      "https://#{ENV['ACTIVE_API_KEY']}:#{ENV['ACTIVE_API_PW']}@#{ENV['ACTIVE_SHOP']}.myshopify.com/admin"
    my_order = ShopifyAPI::Order.find(my_id)
    puts my_order.tags
    mytags = Array.new
    mytags = my_order.tags.split(",")
    puts mytags

    if mytags.include? "3month_nocharge"
        puts "nothing to do, order already tagged"
    elsif
      mytags.push("3month_nocharge")
      my_url = "https://#{ENV['ACTIVE_API_KEY']}:#{ENV['ACTIVE_API_PW']}@#{ENV['ACTIVE_SHOP']}.myshopify.com/admin/orders/#{my_id}.json"
      temp_hash = { "order" => {"id" => my_id, "tags" => mytags} }
      body = temp_hash.to_json
      puts body
      updated_order = HTTParty.put(my_url, :body => body, :timeout => 80, :headers => {"content-type" => 'application/json'})
      if updated_order.code == 200
        puts "order number: #{my_id} updated.."
      elsif
        puts "HTTP ERROR #{updated_order.code} on order #{my_id}"
      end
    end
  end
  puts "process complete"
end

  def self.save_shopify_customers
    init_shopify_customers
    size = SHOPIFY_CUSTOMERS.size
    progressbar = ProgressBar.create(
    title: 'Progess',
    starting_at: 0,
    total: size,
    format: '%t: %p%%  |%B|')

    SHOPIFY_CUSTOMERS.each do |shopify_cust|
    begin
      Customer.create(
      id: shopify_cust.id,
      accepts_marketing: shopify_cust.accepts_marketing || "",
      addresses: shopify_cust.addresses || "",
      default_address: shopify_cust.default_address.to_json,
      email: shopify_cust.email || "",
      first_name: shopify_cust.first_name || "",
      last_name: shopify_cust.last_name || "",
      last_order_id: shopify_cust.last_order_id || "",
      multipass_identifier: shopify_cust.multipass_identifier || "",
      note: shopify_cust.note || "",
      orders_count: shopify_cust.orders_count || "",
      phone: shopify_cust.phone || "",
      state: shopify_cust.state || "",
      tags: shopify_cust.tags || "",
      tax_exempt: shopify_cust.tax_exempt || "",
      total_spent: shopify_cust.total_spent || "",
      verified_email: shopify_cust.verified_email || "",
      created_at: shopify_cust.created_at || "",
      updated_at: shopify_cust.updated_at || ""
      )
      rescue
        puts "error with #{shopify_cust.first_name} #{shopify_cust.last_name}"
        next
      end
      progressbar.increment
    end
    puts 'shopify customers with active subscriptions saved to db..'
  end
  # TODO(Neville Lee): rewrite pull_metafields function without InvalidCustomer table
  def self.pull_metafields
    ShopifyAPI::Base.site =
    "https://#{ENV['ACTIVE_API_KEY']}:#{ENV['ACTIVE_API_PW']}@#{ENV['ACTIVE_SHOP']}.myshopify.com/admin"
    # came from csv of recharge customers who didnt have metafield_value
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

  def self.save_recharge_customers
    # cust = ReCharge::Customer.list(:page => 1, :limit => 1)
    # puts cust[0].id
    init_recharge_customers

    RECHARGE_CUSTOMERS.each do |cust|
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
    puts "recharge customers saved to db"
  end

  def self.save_recharge_subscriptions
    init_recharge_subs
    RECHARGE_SUBS.each do |s|
      puts "saving #{s['id']}"
      begin
      RechargeSubscription.create(
        id: s['id'],
        address_id: s['address_id'],
        customer_id: s['customer_id'],
        created_at: s['created_at'],
        updated_at: s['updated_at'],
        next_charge_scheduled_at: s['next_charge_scheduled_at'],
        cancelled_at: s['cancelled_at'],
        product_title: s['product_title'],
        price: s['price'],
        quantity: s['quantity'],
        status: s['status'],
        shopify_variant_id: s['shopify_variant_id'],
        sku: s['sku'],
        order_interval_frequency: s['order_interval_frequency'],
        order_day_of_month: s['order_day_of_month'],
        order_day_of_week: s['order_day_of_week'],
        properties: s['properties'],
        expire_after_specfic_number_of_charges: s['expire_after_specfic_number_of_charges']
      )
      rescue
        puts "error with subscription id #{s['id']}"
        next
      end
    end
    puts "recharge subscriptions saved to db.."
  end

  def self.save_shopify_orders
    init_shopify_orders
    SHOPIFY_ORDERS.each do |order|
      puts "saving #{order['id']}"
      begin
      ShopifyOrder.create(
        id: order['id'],
        app_id: order['app_id'],
        billing_address1: order['billing_address1'],
        billing_address2: order['billing_address2'],
        browser_ip: order['browser_ip'],
        buyer_accepts_marketing: order['buyer_accepts_marketing'],
        cancel_reason: order['cancel_reason'],
        cancelled_at: order['cancelled_at'],
        cart_token: order['cart_token'],
        client_details: order['client_details'],
        closed_at: order['closed_at'],
        created_at: order['created_at'],
        currency: order['currency',],
        customer: order['customer'],
        customer_locale: order['customer_locale'],
        discount_applications: order['discount_applications'],
        discount_codes: order['discount_codes'],
        email: order['email'],
        financial_status: order['financial_status'],
        fulfillments: order['fulfillments'],
        fulfillment_status: order['fulfillment_status'],
        landing_site: order['landing_site'],
        line_items: order['line_items'],
        location_id: order['location_id'],
        name: order['name'],
        note: order['note'],
        note_attributes: order['note_attributes'],
        number: order['number'],
        order_number: order['order_number'],
        payment_gateway_names: order['payment_gateway_names'],
        phone: order['phone'],
        processed_at: order['processed_at'],
        processing_method: order['processing_method'],
        referring_site: order['referring_site'],
        refunds: order['refunds'],
        shipping_address: order['shipping_address'],
        shipping_lines: order['shipping_lines'],
        source_name: order['source_name'],
        subtotal_price: order['subtotal_price'],
        tags: order['tags'],
        tax_lines: order['tax_lines'],
        taxes_included: order['taxes_included'],
        token: order['token'],
        total_discounts: order['total_discounts'],
        total_line_items_price: order['total_line_items_price'],
        total_price: order['total_price'],
        total_tax: order['total_tax'],
        total_weight: order['total_weight'],
        updated_at: order['updated_at'],
        user_id: order['user_id'],
        order_status_url: order['order_status_url']
      )
      rescue
        puts "error with order id: #{order['id']}"
        next
      end
    end
    puts "shopify orders saved to db.."
  end

  private
  def self.shopify_api_throttle
    ShopifyAPI::Base.site =
      "https://#{ENV['ACTIVE_API_KEY']}:#{ENV['ACTIVE_API_PW']}@#{ENV['ACTIVE_SHOP']}.myshopify.com/admin"
      return if ShopifyAPI.credit_left > 5
      put "api limit reached sleeping 10.."
      sleep 10
  end
  def self.init_recharge_customers
    ReCharge.api_key ="#{ENV['RECHARGE_ELLIE_TOKEN']}"
    customer_count = Recharge::Customer.count
    nb_pages = (customer_count / 250.0).ceil

    1.upto(nb_pages) do |current_page| # throttling conditon
      customers = ReCharge::Customer.list(:page => current_page, :limit => 250)
      RECHARGE_CUSTOMERS.push(customers)
      p "recharge customer set #{current_page}/#{nb_pages} loaded"
      # sleep 1
    end
    p 'recharge customers initialized'
    RECHARGE_CUSTOMERS.flatten!
  end
  def self.init_shopify_customers
    ShopifyAPI::Base.site =
      "https://#{ENV['ACTIVE_API_KEY']}:#{ENV['ACTIVE_API_PW']}@#{ENV['ACTIVE_SHOP']}.myshopify.com/admin"
    active_customer_ids = RechargeCustomer.find_by_sql("
      SELECT DISTINCT rc.shopify_customer_id, rs.status
      FROM recharge_customers rc
      INNER JOIN recharge_subscriptions rs
      ON rc.id = CAST (rs.customer_id AS INTEGER)
      WHERE rs.status = 'ACTIVE';"
    )
    size = active_customer_ids.size
    progressbar = ProgressBar.create(
    title: 'Progess',
    starting_at: 0,
    total: size,
    format: '%t: %p%%  |%B|')

    puts "initializing actively subscribed shopify customers..."
    active_customer_ids.each do |active_cust|
      begin
        shopify_api_throttle
        shopify_cust = ShopifyAPI::Customer.find(active_cust['shopify_customer_id'])
      rescue => error
        puts error
        puts "retrying.."
        sleep 10
        retry
      end
      SHOPIFY_CUSTOMERS.push(shopify_cust)
      progressbar.increment
    end
    puts "active subscription shopify customers initialized!"
  end
  def self.init_recharge_subs
    response = HTTParty.get("https://api.rechargeapps.com/subscriptions/count", :headers => @my_header)
    my_response = JSON.parse(response)
    my_count = my_response['count'].to_i
    nb_pages = (my_count / 250.0).ceil

    1.upto(nb_pages) do |page|
      subs =  HTTParty.get("https://api.rechargeapps.com/subscriptions?limit=250&page=#{page}", :headers => @my_header)
      local_sub = subs['subscriptions']
      local_sub.each do |s|
        RECHARGE_SUBS.push(s)
      end
      p "recharge subscription set #{page}/#{nb_pages} loaded"
      # sleep 1
    end
    p 'recharge subscriptions initialized'
  end
  def self.init_shopify_orders
    ShopifyAPI::Base.site =
      "https://#{ENV['ACTIVE_API_KEY']}:#{ENV['ACTIVE_API_PW']}@#{ENV['ACTIVE_SHOP']}.myshopify.com/admin"
    my_min = '2018-04-01T00:00:00-04:00'
    order_count = ShopifyAPI::Order.count(created_at_min: my_min , status: 'any')
    nb_pages = (order_count / 250.0).ceil
    puts "#{order_count} orders to pull"

    1.upto(nb_pages) do |page|
      ellie_active_url =
        "https://#{ENV['ACTIVE_API_KEY']}:#{ENV['ACTIVE_API_PW']}@#{ENV['ACTIVE_SHOP']}.myshopify.com/admin/orders.json?limit=250&page=#{page}&status=any&created_at_min=2018-05-01T00:00:01-00:00"
      @parsed_response = HTTParty.get(ellie_active_url)

      SHOPIFY_ORDERS.push(@parsed_response['orders'])
      p "active orders set #{page}/#{nb_pages} loaded, sleeping 3"
      sleep 3
    end

    p 'active orders initialized'
    SHOPIFY_ORDERS.flatten!
  end
end
