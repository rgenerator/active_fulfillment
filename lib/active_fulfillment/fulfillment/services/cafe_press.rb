require 'cafe_press/simple_order_api/client'
include CafePress::SimpleOrderAPI

module ActiveMerchant
  module Fulfillment
    class CafePress < Service
      attr_accessor :client, :partner_id

      def initialize(partner_id, options = {})
        @partner_id = partner_id
        @client = Client.new(partner_id, options)
      end

      def fulfill(order_id, shipping_address, line_items, options = {})
        response = @client.create_order(order_id, shipping_address, line_items, options)
        Response.new(true, "Order created: #{response[:order_no]}", response)
      rescue => e # something
        Response.new(false, e.to_s, {})
      end

       def fetch_tracking_data(express_order_id, options = {})
        @client.get_shipping_info(express_order_id, options)
      end

      def get_order_status(express_order_id, options = {})
         @client.get_order_status(express_order_id, options)
      end

      def cancel_order(express_order_id, options = {})
        @client.cancel_order(express_order_id, options)
      end

      def get_order_by_internal_id(identiciation_code, internal_order_id, options = {})
         @client.get_order_by_secondary_identifier(identiciation_code, internal_order_id, options)
      end

    end
  end
end
