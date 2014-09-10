require 'cafepress/ezp/client'
include CafePress::EZP

module ActiveMerchant
  module Fulfillment
    class CafePress < Service
      cattr_accessor :logger
      attr_accessor :client

      def initialize(options = {})
      	check_test_mode(options)
        initialize_ezp_client(options)
        @options = {}
        @options.update(options)
      end

      def test_mode?
        false
      end

      def test?
        @options[:test] || Base.mode == :test
      end

      def valid_credentials?
        true
      end

      def fulfill(order_id, shipping_address, line_items, options = {})
        requires!(options, :order_id, :shipping_address,:line_items)
        client.place_order(customer, order, order_items)
      end

      def fetch_stock_levels(options = {})
        raise NotImplementedError.new("Subclasses must implement")
      end

      def fetch_tracking_numbers(order_ids, options = {})
        response = fetch_tracking_data(order_ids, options)
        response.params.delete('tracking_companies')
        response.params.delete('tracking_urls')
        response
      end

      def fetch_tracking_data(order_ids, options = {})
        raise NotImplementedError.new("Subclasses must implement")
      end

      private

      def initialize_ezp_client(options)
      	requires!(options, :partner_id, :vendor_name)
      	Client.config do
          secure = true
          partner_id = partner_id
          vendor.name = vendor_name
          # ...
        end
        @client = Client.new
      end

      def check_test_mode(options)
        if options[:test] and not test_mode?
          raise ArgumentError, 'Test mode is not supported by this gateway'
        end
      end
    end
  end
end
