# API

## Get Orders count

~~~sh
curl -i --insecure -X GET http://localhost:3000/hels
~~~

## Debug Order creation:

~~~sh
curl -i -X POST http://localhost:3000/orders \
    -H "Content-Type: application/json" \
    -d '{"order": {"psp": "debug", "currency": "GBP", "country_code": "GB", "email": "herbert.conroy@email.com", "first_name": "Herbert", "last_name": "Conroy", "address1": "930 Kiehn Walks", "address2": "44216", "city": "Lake Terrance", "postal_code": "67570-3035", "line_items": [{"product_variant": "ab-roller/blue", "quantity": 1}]}}'
~~~
