module OrderCreator
  def self.call(opts)
    currency = opts[:currency]
    opts[:email] = nulify_string(opts[:email])
    opts[:zone] = nulify_string(opts[:zone])
    opts[:address2] = nulify_string(opts[:address2])
    order = Order.create!(opts.slice(:psp, :currency, :country_code, :email, :first_name, :last_name, :address1, :address2, :city, :zone, :postal_code))

    line_items = opts[:line_items].map do |h|
      product_variant_key = nulify_string(h[:product_variant])
      quantity = [h[:quantity].to_i, 1].max
      product_variant = PRODUCT_VARIANTS.fetch(product_variant_key)
      unit_amount = product_variant.fetch(currency)
      LineItem.create!(order:, product_variant_key:, unit_amount:, quantity:)
    end
    order.update_columns(total_amount: line_items.map(&:subtotal_amount).sum)
    [order, line_items]
  end

  def self.nulify_string(val)
    (val.is_a?(String) && !val.empty?) ? val : nil
  end
end
