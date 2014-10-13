require 'cafe_press/simple_order_api/client'

module ActiveMerchant
  module Fulfillment
    class CafePress < Service
      include ::CafePress::SimpleOrderAPI

      attr_accessor :client, :partner_id

      def initialize(options = {})
        super

        options = options.dup
        requires!(options, :partner_id)

        @partner_id = options.delete(:partner_id)
        @client = Client.new(partner_id, options)
      end

      def fulfill(order_id, shipping_address, line_items, options = {})
        response = @client.create_order(order_id, shipping_address, line_items, options)
        Response.new(true, "Order created: #{response[:order_no]}", response)
      rescue Error => e
        Response.new(false, e.to_s)
      end

       def fetch_tracking_data(express_order_id, options = {})
         begin
           response = @client.get_shipping_info(express_order_id, options)
           Response.new(true, "Get Shipment Info response", response)
         rescue Error => e
          Response.new(false, e.to_s)
        end
      end

      def fetch_stock_levels(options = {})
        raise NotImplementedError, 'fetch_stock_levels is not implemented'
      end

      # Yes, there's a test environment
      def test_mode?
        true
      end

      ###########
      # MP specific
      ###########

      def get_order_status(express_order_id, options = {})
        begin
          response = @client.get_order_status(express_order_id, options)
          Response.new(true, "Get Order Status response", response)
        rescue Error => e
          Response.new(false, e.to_s)
        end
      end

      def cancel_order(express_order_id, options = {})
        begin
          response = @client.cancel_order(express_order_id, options)
          Response.new(true, "Cancel Order response", response)
        rescue Error => e
          Response.new(false, e.to_s)
        end
      end

      def get_order_by_internal_id(identiciation_code, internal_order_id, options = {})
         begin
          response = @client.get_order_by_secondary_identifier(identiciation_code, internal_order_id, options)
          Response.new(true, "Get Shipment Info response", response)
        rescue Error => e
          Response.new(false, e.to_s)
        end
      end

    end
  end
end
