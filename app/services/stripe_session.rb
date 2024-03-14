module StripeSession
  def self.create(order, line_items)
    currency = order.currency.downcase
    session = Stripe::Checkout::Session.create(
      line_items: line_items.map do |li|
        {
          price_data: {
            currency:,
            product_data: {name: li.product_name},
            unit_amount: li.unit_amount
          },
          quantity: li.quantity
        }
      end,
      mode: "payment",
      success_url: ORDERS_URL + "/orders/success?t=" + order.token,
      cancel_url: ORDERS_URL + "/orders/cancel?t=" + order.token
    )
    order.update(stripe_session_id: session.id, updated_at: Time.now.utc)
    session
  end
end
