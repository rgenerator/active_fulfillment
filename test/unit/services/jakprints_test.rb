require 'test/test_helper'

class JakprintsTest < Test::Unit::TestCase
  def setup
     @service = Jakprints.new(
		  :url => 'https://sandbox.prod.jakprints.com',
                  :username => 'test',
                  :password => 'test'
                )

     @options = {
      
     }

     @address = { :name => 'Bob Saget',
                  :address1 => '820 Crest Ave',
                  :address2 => 'Apt 66',
                  :city => 'Queens',
                  :state => 'NY',
                  :country => 'US',
                  :zip => '14033'
                 }

     @line_items = [
       { :sku => '999777666561',
         :quantity => 1
       }
     ]
  end

  def test_successful_fulfillment
    @service.expects(:create_order).returns(successful_fulfillment_response)
    response = @service.fulfill('12345678', @address, @line_items, @options)
    assert response.success?
  end
  
  def test_invalid_arguments
    response = @service.fulfill('12345678', {}, @line_items, @options)
    assert !response.success?
    assert_equal "Missing required parameter: name", response.message
  end


  private

  def build_mock_response(response, message, code = "200")
    http_response = mock(:code => code, :message => message)
    http_response.stubs(:body).returns(response)
    http_response
  end


  def successful_fulfillment_response
    {"Order"=>{"id"=>"37414", "order_date"=>"2014-09-17 11:42:49", "client_ref"=>"11234", "status_shipped"=>false, "status_invoiced"=>false, "status_new"=>false, "status_hold"=>false, "status_cancelled"=>false},
   "Shipment"=>{"first"=>"Bob", "last"=>"Saget", "attention"=>"", "address1"=>"820 Crest Ave", "address2"=>"Apt 66", "city"=>"Queens", "state"=>"NY", "zip"=>"14033", "trackingnumber"=>nil, "shipdate"=>nil, "client_ref"=>""},
   "OrderItem"=>
    [{"id"=>"56411",
      "quantity"=>"1",
      "status_printed"=>false,
      "client_ref"=>"",
      "product_id"=>"17034",
      "order_id"=>"37414",
      "Product"=>
       {"id"=>"17034",
        "sku"=>"121212",
        "description"=>"Test Product 1",
        "substrate_id"=>"170",
        "Substrate"=>{"id"=>"170", "manufacturer"=>"Alstyle", "manufacturer_number"=>"1301", "color"=>"black", "size"=>"sm"},
        "Graphic"=>[]}}]}
  end

end