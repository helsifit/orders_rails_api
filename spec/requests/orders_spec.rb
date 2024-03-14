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

      it "creates order with debug PSP" do
        post "/orders", params: {order: valid_attributes}

        expect(response).to be_redirect
        expect(response.headers["Location"]).to eq("http://localhost:9000/success.html")
        expect(order.total_amount).to eq(5499)
        expect(order.token).to_not be_nil
        expect(order.stripe_session_id).to be_nil
        expect(order.line_items[0].attributes.values_at("product_variant_key", "unit_amount", "quantity")).to eq(["ab-roller/blue", 5499, 1])
      end

      it "creates order and redirects to Stripe session", vcr: {cassette_name: "stripe/create_session"} do
        post "/orders", params: {order: valid_attributes.merge(psp: "stripe")}

        expect(response).to be_redirect
        expect(response.headers["Location"]).to start_with("https://checkout.stripe.com/c/pay/cs_test_")
        expect(order.stripe_session_id).to start_with("cs_test_")
        expect(order.token).to_not be_nil
        expect(order.total_amount).to eq(5499)
      end
    end

    context "with invalid parameters" do
      context "invalid currency" do
        let(:invalid_attributes) { valid_attributes.merge(currency: "EEE") }

        it "saves invalid new Order" do
          expect {
            post orders_url,
              params: {order: invalid_attributes}, as: :json
          }.to change(Order, :count).by(1)
        end

        it "redirects with error" do
          post "/orders", params: {order: invalid_attributes}, as: :json

          expect(response).to be_redirect
          expect(response.headers["Location"]).to eq("http://localhost:9000/error.html?error=Sorry%2C+we+cannot+process+the+order%3A+Currency+cannot+be+used+at+this+moment.")
        end
      end

      context "invalid product_variant" do
        let(:invalid_attributes) { valid_attributes.merge(line_items: [{product_variant: "sombrero", quantity: 1}]) }

        it "create empty Order" do
          expect {
            post orders_url,
              params: {order: invalid_attributes}, as: :json
          }.to change(Order, :count).by(1)
          expect(order.line_items.count).to eq(1)
        end

        it "redirects with error" do
          post "/orders", params: {order: invalid_attributes}, as: :json

          expect(response).to be_redirect
          expect(response.headers["Location"]).to eq("http://localhost:9000/error.html?error=Sorry%2C+we+cannot+process+the+order%3A+Product+variant+is+unknown.")
        end
      end
    end
  end

  describe "success callback" do
    let(:order) { Order.create(valid_attributes.except(:line_items)) }

    context "pending order" do
      it "marks order as paid and redirects to frontend success page" do
        order.update(paid: false, canceled: false, updated_at: Time.now.utc - 86400)
        get "/orders/success?t=#{order.token}"

        expect(order.reload.paid).to eql(true)
        expect(response).to be_redirect
        expect(response.headers["Location"]).to eq("http://localhost:9000/success.html")
      end
    end

    context "paid order" do
      it "does not update order and redirects to frontend success page" do
        order.update(paid: true, canceled: false, updated_at: Time.now.utc - 86400)
        expect {
          get "/orders/success?t=#{order.token}"
        }.not_to change { order.reload.updated_at }

        expect(order.reload.paid).to eql(true)
        expect(response).to be_redirect
        expect(response.headers["Location"]).to eq("http://localhost:9000/success.html")
      end
    end

    context "canceled order" do
      it "does not update order and redirects to frontend success page" do
        order.update(paid: false, canceled: true, updated_at: Time.now.utc - 86400)
        expect {
          get "/orders/success?t=#{order.token}"
        }.not_to change { order.reload.updated_at }

        expect(order.reload.paid).to eql(false)
        expect(response).to be_redirect
        expect(response.headers["Location"]).to eq("http://localhost:9000/success.html")
      end
    end
  end

  describe "callback to cancel order" do
    let(:order) { Order.create(valid_attributes.except(:line_items)) }

    context "pending order" do
      it "marks order as paid and redirects to frontend success page" do
        order.update(paid: false, canceled: false, updated_at: Time.now.utc - 86400)
        get "/orders/cancel?t=#{order.token}"

        expect(order.reload.paid).to eql(false)
        expect(order.reload.canceled).to eql(true)
        expect(response).to be_redirect
        expect(response.headers["Location"]).to eq("http://localhost:9000/cancel.html")
      end
    end

    context "paid order" do
      it "does not update order and redirects to frontend success page" do
        order.update(paid: true, canceled: false, updated_at: Time.now.utc - 86400)
        expect {
          get "/orders/cancel?t=#{order.token}"
        }.not_to change { order.reload.updated_at }

        expect(order.reload.paid).to eql(true)
        expect(order.reload.canceled).to eql(false)
        expect(response).to be_redirect
        expect(response.headers["Location"]).to eq("http://localhost:9000/cancel.html")
      end
    end

    context "canceled order" do
      it "does not update order and redirects to frontend success page" do
        order.update(paid: false, canceled: true, updated_at: Time.now.utc - 86400)
        expect {
          get "/orders/cancel?t=#{order.token}"
        }.not_to change { order.reload.updated_at }

        expect(order.reload.paid).to eql(false)
        expect(order.reload.canceled).to eql(true)
        expect(response).to be_redirect
        expect(response.headers["Location"]).to eq("http://localhost:9000/cancel.html")
      end
    end
  end
end
