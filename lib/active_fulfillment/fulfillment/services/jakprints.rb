require 'jakprints'

module ActiveMerchant
  module Fulfillment
    class Jakprints < Service
      attr_accessor :client, :partner_id

      def initialize(options = {})
        super
        requires!(options, :partner_id)
        @partner_id = options[:partner_id]
        options.delete(:partner_id)
        @client = Client.new(partner_id, options)
        super
      end

      def fulfill(order_id, shipping_address, line_items, options = {})
        response = @client.create_order(order_id, shipping_address, line_items, options)
        Response.new(true, "Order created: #{response[:order_no]}", response)
      rescue => e # something
        Response.new(false, e.to_s, response)
      end

      def fetch_tracking_data(express_order_id, options = {})
        begin
          response = @client.get_shipping_info(express_order_id, options)
          Response.new(true, "Get Shipment Info response", response)
        rescue => e # something
          Response.new(false, e.to_s, response)
        end
      end

      def fetch_stock_levels(options = {})
        raise NotImplementedError, 'fetch_stock_levels is not implemented'
      end

      def cancel_order(express_order_id, options = {})
        begin
          response = @client.cancel_order(express_order_id, options)
          Response.new(true, "Cancel Order response", response)
        rescue => e # something
          Response.new(false, e.to_s, response)
        end
      end

    end
  end
end
