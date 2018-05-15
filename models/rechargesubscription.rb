class RechargeSubscription < ActiveRecord::Base
  self.table_name = 'recharge_subscriptions'
  belongs_to :recharge_customer, inverse_of: :recharge_subscription, foreign_key: "customer_id"
end
