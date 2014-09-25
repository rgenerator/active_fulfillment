# Active Fulfillment
Active Merchant library for integration with order fulfillment services.

# Installation

Add to your gem file
```
gem 'active_fulfillment', :git => 'git://github.com/rgenerator/active_fulfillment.git'
```

# Method Names and Signatures
For sending order information to fulfiller
```
fulfill(order_id, shipping_address, line_items, options = {})
```
order_id is internal order identifier
shipping_address format (hash with keys)
    name
    address1
    address2
    address3
    city
    state
    country
    zip
    phone

line_items format (array of hashes)
    sku
    quantity
    price
    shipping_price
    and options hash

Any other extra information goes into options hash