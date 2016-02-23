require 'jakprints'
require 'json'

module ActiveMerchant
  module Fulfillment
    class Jakprints < Service
      TEST_URL = "https://sandbox.pod.jakprints.com"

      def initialize(options = {})
        super

        requires!(options, :username, :password)

        if test?
          options[:url] = TEST_URL
          # Jakprints sandbox has bad cert
          options[:ssl] = { :verify => false }
        end

        ::Jakprints.configure options
      end

      def fulfill(order_id, shipping_address, line_items, options = {})
        requires!(shipping_address, :name, :address1, :city, :state, :zip)

        line_items.each do |item|
          requires!(item, :sku, :quantity)
        end

        request = build_fulfillment_request(order_id, shipping_address, line_items)
        response = create_order(request)
        # Check for an error response.
        # TODO: This check should be in Jakprints::Client.
        if response[:code]
          error = response[:message]
          Response.new(false, "Order error: #{error}")
        else
          Response.new(true, "Order created: #{response['Order']['id']}", response)
        end
      rescue ArgumentError => e
        # ArgumentError if fields are missing
        Response.new(false, "Invalid order: #{e}")
      rescue => e
        # TODO: what can be raised from Jakprints?
        raise ActiveMerchant::ConnectionError, e.to_s
      end

      def fetch_tracking_data(order_id, options = {})
        raise NotImplementedError, 'fetch_tracking_data is not implemented'
      end

      def fetch_stock_levels(options = {})
        raise NotImplementedError, 'fetch_stock_levels is not implemented'
      end

      def cancel_order(express_order_id, options = {})
        begin
          cancel_order_response = ::Jakprints::Order.update_order(express_order_id, build_cancel_order_request)
          Response.new(true, "Cancel Orderresponse", cancel_order_response.attributes)
        rescue => e
          Response.new(false, e.to_s)
        end
      end

      def test_mode?
       true
      end

      private

      def build_cancel_order_request
        {'Order' => {'status_cancelled' => true} }
      end

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
