require 'cafe_press/simple_order_api/client'
include CafePress::SimpleOrderAPI

module ActiveMerchant
  module Fulfillment
    class CafePress < Service
      attr_accessor :client, :partner_id

      def initialize(options = {})
        requires!(options, :partner_id)
        @partner_id = options[:partner_id]
        options.delete(:partner_id)
        @client = Client.new(partner_id, options)
        super
      end

      def fulfill(order_id, shipping_address, line_items, options = {})
        send_request do
          response = @client.create_order(order_id, shipping_address, line_items, options)
          Response.new(true, "Order created: #{response[:order_no]}", response)
        end
      end

      def test_mode?
        true
      end

       def fetch_tracking_data(express_order_id, options = {})
         send_request do
           response = @client.get_shipping_info(express_order_id, options)
           Response.new(true, "Get Shipment Info response", response)
         end
      end

      def send_request
        yield
      rescue ::CafePress::SimpleOrderAPI::InvalidRequestError => e
        Response.new(false, e.to_s)
      rescue ::CafePress::SimpleOrderAPI::ConnectionError => e
        raise ActiveMerchant::ConnectionError, e.to_s
      end

      def fetch_stock_levels(options = {})
        raise NotImplementedError, 'fetch_stock_levels is not implemented'
      end

      ###########
      # MP specific
      ###########

      def get_order_status(express_order_id, options = {})
        send_request do
          response = @client.get_order_status(express_order_id, options)
          Response.new(true, "Get Order Status response", response)
        end
      end

      def cancel_order(express_order_id, options = {})
        send_request do
          response = @client.cancel_order(express_order_id, options)
          Response.new(true, "Cancel Order response", response)
        end
      end

      def get_order_by_internal_id(identiciation_code, internal_order_id, options = {})
         send_request do
          response = @client.get_order_by_secondary_identifier(identiciation_code, internal_order_id, options)
          Response.new(true, "Get Shipment Info response", response)
        end
      end

    end
  end
end
