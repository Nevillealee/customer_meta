class RechargeCustomer < ActiveRecord::Base
  self.table_name = 'recharge_customers'
  has_many :recharge_subscriptions, inverse_of: :recharge_customer
end
