module ActiveMerchant
  module Fulfillment
    class ShopifyAPIService < Service

      RESCUABLE_CONNECTION_ERRORS = [
        Net::ReadTimeout,
        Net::OpenTimeout,
        TimeoutError,
        Errno::ETIMEDOUT,
        Timeout::Error,
        IOError,
        EOFError,
        SocketError,
        Errno::ECONNRESET,
        Errno::ECONNABORTED,
        Errno::EPIPE,
        Errno::ECONNREFUSED,
        Errno::EAGAIN,
        Errno::EHOSTUNREACH,
        Errno::ENETUNREACH,
        Resolv::ResolvError,
        Net::HTTPBadResponse,
        Net::HTTPHeaderSyntaxError,
        Net::ProtocolError,
        ActiveMerchant::ConnectionError,
        ActiveMerchant::ResponseError
      ]

      def initialize(options={})
        @format = options[:format]
        @domain = options[:domain]
        @callback_url = options[:callback_url]
        @api_permission = options[:api_permission]
        @name = options[:name]
      end

      def fulfill(order_id, shipping_address, line_items, options = {})
        raise NotImplementedError.new("Shopify API Service must listen to fulfillment/create Webhooks")
      end

      def fetch_stock_levels(options = {})
        response = send_app_request('fetch_stock', options.slice(:sku))
        if response
          stock_levels = parse_response(response, 'StockLevels', 'Product', 'Sku', 'Quantity') { |p| p.to_i }
          Response.new(true, "API stock levels", {:stock_levels => stock_levels})
        else
          Response.new(false, "Unable to fetch remote stock levels")
        end
      end

      def fetch_tracking_data(order_ids, options = {})
        response = send_app_request('fetch_tracking_numbers', {:order_ids => order_ids})
        if response
          tracking_numbers = parse_response(response, 'TrackingNumbers', 'Order', 'ID', 'Tracking') { |o| o }
          Response.new(true, "API tracking_numbers", {:tracking_numbers => tracking_numbers,
                                                    :tracking_companies => {},
                                                    :tracking_urls => {}})
        else
          Response.new(false, "Unable to fetch remote tracking numbers #{order_ids.inspect}")
        end
      end

      private

      def request_uri(action, data)
        data['timestamp'] = Time.now.utc.to_i
        data['shop'] = @domain

        URI.parse "#{@callback_url}/#{action}.#{@format}?#{data.to_param}"
      end

      def send_app_request(action, data)
        uri = request_uri(action, data)
        logger.info "[" + @name.upcase + " APP] Post #{uri}"

        response = nil
        realtime = Benchmark.realtime do
          begin
            Timeout.timeout(20.seconds) do
              response = ssl_get(uri, headers(data.to_param))
            end
          rescue *(RESCUABLE_CONNECTION_ERRORS) => e
            logger.warn "[#{self}] Error while contacting fulfillment service error =\"#{e.message}\""
          end
        end

        line = "[" + @name.upcase + "APP] Response from #{uri} --> "
        line << "#{response} #{"%.4fs" % realtime}"
        logger.info line

        response
      end

      def parse_response(response, root, type, key, value)
        case @format
        when 'json'
          response_data = ActiveSupport::JSON.decode(response)
          return {} unless response_data.is_a?(Hash)
          response_data[root.underscore] || response_data
        when 'xml'
          response_data = {}
          document = REXML::Document.new(response)
          document.elements[root].each do |node|
            if node.name == type
              response_data[node.elements[key].text] = node.elements[value].text
            end
          end
          response_data
        end

      rescue ActiveSupport::JSON.parse_error, REXML::ParseException
        {}
      end

      def encode_payload(payload, root)
        case @format
        when 'json'
          {root => payload}.to_json
        when 'xml'
          payload.to_xml(:root => root)
        end
      end

      def headers(data)
        {
          'X-Shopify-Shop-Domain' => @domain,
          'X-Shopify-Hmac-SHA256' => @api_permission.api_client.hmac(data),
          'Content-Type'          => "application/#{@format}"
        }
      end

    end
  end
end
