# Active Fulfillment
Active Merchant library for integration with order fulfillment services.

# Installation

Add to your gem file
```
gem 'active_fulfillment', :git => 'git://github.com/rgenerator/active_fulfillment.git'
```

# Method Names and Signatures
### For sending order information to fulfiller
```
fulfill(order_id, shipping_address, line_items, options = {})
```
* order_id is internal order identifier
* shipping_address format (hash with keys)
    1. name
    2. address1
    3. address2
    4. address3
    5. city
    6. state
    7. country
    8. zip
    9. phone

* line_items format (array of hashes)
    1. sku
    2. quantity
    3. price
    4. shipping_price
    5. options hash

* Any other extra information goes into options hash

# Currently supporting
## Cafe Press
   Cafe Press specific methods
   1. Fetching the current data
   ```
     fetch_tracking_data(cafe_press_order_id)
   ```
   2. Getting current order status
   ```
     get_order_status(cafe_press_order_id)
   ```
   3. Cancel an order
   ```
     cancel_order(cafe_press_order_id)
   ```

