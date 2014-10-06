require 'jakprints'

module ActiveMerchant
  module Fulfillment
    class Jakprints < Service
      attr_accessor :client, :partner_id

      def initialize(options = {})
        requires!(options, :url, :username, :password)
        Jakprints.configure options
        super
      end

      def fulfill(order_id, shipping_address, line_items, options = {})
        requires!(shipping_address, :first_name, :last_name, :address1, :city, :state, :zip_code)
        line_items.each do |item|
          requires!(item, :sku, :quantity)
        end
        request = build_fulfillment_request(order_id, shipping_address, line_items)
        created_order = Jakprints::Order.add_order(request)
        Response.new(true, "Order created: #{created_order.Order['id']}", created_order.attributes)
      rescue => e # something
        Response.new(false, e.to_s, created_order)
      end

      def fetch_tracking_data(jakprints_order_id, options = {})
        begin
          order_response = Jakprints::Order.get_by_id(jakprints_order_id, options)
          Response.new(true, "Get Shipment Info response", order_response.attributes)
        rescue => e # something
          Response.new(false, e.to_s, order_response)
        end
      end

      def fetch_stock_levels(options = {})
        raise NotImplementedError, 'fetch_stock_levels is not implemented'
      end

      def cancel_order(express_order_id, options = {})
        raise NotImplementedError, 'cancel_order is not implemented'
      end
      
      private
      def build_fulfillment_request(order_id, shipping_address, line_items)
        request = {}
        request['Order']['client_ref'] = order_id
        request['Shipment']['first'] = shipping_address['first_name']
        request['Shipment']['last'] = shipping_address['last_name']
        request['Shipment']['address1'] = shipping_address['address1']
        request['Shipment']['address2'] = shipping_address['address2'] if shipping_address['address2']
        request['Shipment']['city'] = shipping_address['city']
        request['Shipment']['state'] = shipping_address['state']
        request['Shipment']['zip'] = shipping_address['zip_code']
        request['OrderItems'] = line_items.collect do |item|
          { 'sku' => item['sku'], 'quantity' => item['quantity']}
        end
      end

    end
  end
end
