require 'cafe_press/simple_order_api/client'
include CafePress::SimpleOrderAPI

module ActiveMerchant
  module Fulfillment
    class CafePress < Service
      cattr_accessor :logger
      attr_accessor :client

      def initialize(partner_id)
        @client = Client.new(partner_id)
      end

      def fulfill(order_id, shipping_address, line_items, options = {})
        requires!(options, :customer, :order)
        @client.place_order(options[:customer], options[:order], line_items, shipping_address)
      end

    end
  end
end
