require 'cafe_press/ezp/client'
include CafePress::EZP

module ActiveMerchant
  module Fulfillment
    class CafePress < Service
      cattr_accessor :logger
      attr_accessor :client

      def initialize(options = {})
        initialize_ezp_client(options)
        @options = {}
        @options.update(options)
      end

      def fulfill(order_id, shipping_address, line_items, options = {})
        requires!(options, :customer, :order)
        @client.place_order(options[:customer], options[:order], line_items, shipping_address)
      end

      private
      def initialize_ezp_client(options)
        requires!(options, :partner_id, :vendor)
        @client = Client.new(options[:partner_id], options[:vendor])
      end

    end
  end
end
