module PaymentInitiator
  def self.call(order, line_items)
    case order.psp
    when Order::STRIPE
      session = StripeSession.create(order, line_items)
      session.url
    else
      SHOP_URL + "/success.html"
    end
  end
end
