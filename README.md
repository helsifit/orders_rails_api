# Orders API using Rails

## Dependencies

PostgreSQL version >= 12, Ruby version 3.3.0

## Setup

Install Ruby gems and copy sample env files:

~~~sh
bin/setup
~~~

Edit development settings and add Stripe testing API key in `.env` file.

## RSpec Testing:

~~~sh
bundle exec rspec
~~~

## Development

Start development server:

~~~sh
bundle exec rails server
~~~

## [API](/API.md)

Create Order with JSON data:

~~~sh
curl -i -X POST http://localhost:3000/orders \
    -H "Content-Type: application/json" \
    -d '{"order": {"psp": "debug", "country_code": "GB", "currency": "GBP", "email": "herbert.conroy@email.com", "first_name": "Herbert", "last_name": "Conroy", "address1": "930 Kiehn Walks", "address2": "44216", "city": "Lake Terrance", "postal_code": "67570-3035", "line_items": [{"product_variant": "ab-roller/blue", "quantity": 1}]}}'
~~~

Create Order with form-urlencoded data:

~~~sh
curl -i -X POST http://localhost:3000/orders \
   -H "Content-Type: application/x-www-form-urlencoded" \
   -d "order[psp]=debug&order[country_code]=GB&order[currency]=GBP&order[email]=herbert.conroy@email.com&order[first_name]=Herbert&order[last_name]=Conroy&order[address1]=930 Kiehn Walks&order[address2]=44216&order[city]=Lake Terrance&order[postal_code]=67570-3035&order[line_items][][product_handle]=ab-roller/blue&order[line_items][][quantity]=1"
~~~

### Stripe Payment Service Provider

Creating order with `psp=stripe` redirects to Stripe. After a successful payment, Stripe calls the Orders API /orders/success callback and that redirects to the /success.html frontend page.
