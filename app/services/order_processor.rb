module OrderProcessor
  def self.call(opts)
    order, line_items = OrderCreator.call(opts)
    OrderValidator.call(order, line_items)
    PaymentInitiator.call(order, line_items)
  end
end
