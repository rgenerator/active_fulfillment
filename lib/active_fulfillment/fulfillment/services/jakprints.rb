require 'jakprints'

module ActiveMerchant
  module Fulfillment
    class Jakprints < Service
      TEST_URL = "sandpod.pod.jakprints.com"

      def initialize(options = {})
        requires!(options, :username, :password)
        options[:url] = TEST_URL if test?

        ::Jakprints.configure options

        super
      end

      def fulfill(order_id, shipping_address, line_items, options = {})
        requires!(shipping_address, :name, :address1, :city, :state, :zip)

        line_items.each do |item|
          requires!(item, :sku, :quantity)
        end

        request = build_fulfillment_request(order_id, shipping_address, line_items)
        created_order = create_order(request)
        Response.new(true, "Order created: #{created_order['Order']['id']}", created_order)
      rescue ArgumentError => e
        # ArgumentError if fields are missing
        Response.new(false, "Invalid order: #{e}")
      rescue => e
        # TODO: what can be raised from Jakprints?
        raise ActiveMerchant::ConnectionError, e.to_s
      end

      def fetch_tracking_data(order_id, options = {})
        order_response = ::Jakprints::Order.get_by_id(order_id)
        # nil if no order?
        if order_response.nil?
          Response.new(false, "Order not found #{order_id}")
        else
          Response.new(true, "Get Shipment Info response", order_response.attributes)
        end
      rescue => e
        # TODO: what can be raised from Jakprints?
        raise ActiveMerchant::ConnectionError, e.to_s
      end

      def fetch_stock_levels(options = {})
        raise NotImplementedError, 'fetch_stock_levels is not implemented'
      end

      def cancel_order(express_order_id, options = {})
        raise NotImplementedError, 'cancel_order is not implemented'
      end

      def test_mode?
       true
      end

      private
      def build_fulfillment_request(order_id, shipping_address, line_items)
        request = {}
        request[:Order] = { :client_ref => order_id }
        request[:Shipment] = {}
        first, last = shipping_address[:name].split(' ') if shipping_address[:name]
        request[:Shipment][:first] = first || shipping_address[:first]
        request[:Shipment][:last] = last || shipping_address[:last]
        request[:Shipment][:address1] = shipping_address[:address1]
        request[:Shipment][:address2] = shipping_address[:address2] if shipping_address[:address2]
        request[:Shipment][:city] = shipping_address[:city]
        request[:Shipment][:state] = shipping_address[:state]
        request[:Shipment][:zip] = shipping_address[:zip]
        request[:Shipment][:country] = shipping_address[:country] if shipping_address[:country]
        request[:Shipment][:phone] = shipping_address[:phone] if shipping_address[:phone]
        request[:OrderItems] = line_items.collect do |item|
          { :sku => item[:sku], :quantity => item[:quantity]}
        end
        request
      end

      def create_order(request)
        order = ::Jakprints::Order.add_order(request)
        order.attributes
      end

    end
  end
end
