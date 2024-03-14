require "rails_helper"

RSpec.describe "/orders", type: :request do
  let(:valid_attributes) {
    {
      psp: "dummy",
      currency: "GBP",
      country_code: "GB",
      email: Faker::Internet.email,
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      address1: Faker::Address.street_address,
      address2: Faker::Address.building_number,
      city: Faker::Address.city,
      zone: "",
      postal_code: Faker::Address.postcode,
      line_items: [{
        product_variant: "ab-roller/blue",
        quantity: 1
      }]
    }
  }

  # This should return the minimal set of values that should be in the headers
  # in order to pass any filters (e.g. authentication) defined in
  # OrdersController, or in your router and rack
  # middleware. Be sure to keep this updated too.
  let(:valid_headers) {
    {}
  }
  let(:order) { Order.last }

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Order" do
        expect {
          post orders_url,
            params: {order: valid_attributes}, headers: valid_headers, as: :json
        }.to change(Order, :count).by(1)
      end

      it "renders a JSON response with the new order" do
        post orders_url,
          params: {order: valid_attributes}, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including("application/json"))
        expect(response.parsed_body).to eq({
          "id" => order.id,
          "country_code" => "GB",
          "currency" => "GBP",
          "total_amount" => 5499,
          "line_items" => [{"product_variant_key" => "ab-roller/blue", "unit_amount" => 5499, "quantity" => 1}]
        })
      end

      it "creates order and redirects to Stripe session", vcr: {cassette_name: "stripe/create_session"} do
        post "/orders", params: {order: valid_attributes.merge(psp: "stripe")}

        expect(response).to be_redirect
        expect(response.headers["Location"]).to start_with("https://checkout.stripe.com/c/pay/cs_test_")
        expect(order.stripe_session_id).to start_with("cs_test_")
        expect(order.token).to_not be_nil
      end
    end

    context "with invalid parameters" do
      context "invalid currency" do
        let(:invalid_attributes) { valid_attributes.merge(currency: "EEE") }

        it "does not create a new Order" do
          expect {
            post orders_url,
              params: {order: invalid_attributes}, as: :json
          }.to change(Order, :count).by(0)
        end

        it "redirects with error" do
          post "/orders", params: {order: invalid_attributes}, as: :json

          expect(response).to be_redirect
          expect(response.headers["Location"]).to eq("http://localhost:9000/error.html?error=Currency+cannot+be+used+at+this+moment")
        end
      end

      context "invalid product_variant" do
        let(:invalid_attributes) { valid_attributes.merge(line_items: [{product_variant: "sombrero", quantity: 1}]) }

        it "create empty Order" do
          expect {
            post orders_url,
              params: {order: invalid_attributes}, as: :json
          }.to change(Order, :count).by(1)
          expect(order.line_items).to be_empty
        end

        it "redirects with error" do
          post "/orders", params: {order: invalid_attributes}, as: :json

          expect(response).to be_redirect
          expect(response.headers["Location"]).to eq("http://localhost:9000/error.html?error=Unexpected+error")
        end
      end
    end
  end

  describe "success callback" do
    it "marks order as paid and redirects to frontend success page" do
      order = Order.create(valid_attributes.except(:line_items))
      get "/orders/success?t=#{order.token}"

      expect(order.reload).to be_paid
      expect(response).to be_redirect
      expect(response.headers["Location"]).to eq("http://localhost:9000/success.html")
    end
  end
end
