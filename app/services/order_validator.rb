module OrderValidator
  class ValidationError < StandardError; end

  def self.call(order, line_items)
    raise ValidationError, "Payment service provider cannot be used at this moment." if !order.psp || order.psp.empty?
    raise ValidationError, "Currency cannot be used at this moment." if !order.currency || order.currency.empty? || !Order::CURRENCIES.include?(order.currency)
    raise ValidationError, "Country code cannot be empty." if !order.country_code || order.country_code.empty?
    raise ValidationError, "First name cannot be empty." if !order.first_name || order.first_name.empty?
    raise ValidationError, "Last name cannot be empty." if !order.last_name || order.last_name.empty?
    raise ValidationError, "Address line1 cannot be empty." if !order.address1 || order.address1.empty?
    raise ValidationError, "City cannot be empty." if !order.city || order.city.empty?
    raise ValidationError, "City zone cannot be empty." if order.country_code == "US" && (!order.zone || order.zone.empty?)
    raise ValidationError, "Postal code cannot be empty." if !order.postal_code || order.postal_code.empty?

    line_items.each do |li|
      raise ValidationError, "Product variant is unknown." unless PRODUCT_VARIANTS.key?(li.product_variant_key)
      raise ValidationError, "Product price for chosen currency is unknown." unless li.unit_amount && li.unit_amount > 0
      raise ValidationError, "Each item quantity must be positive." unless li.quantity.is_a?(Integer) && li.quantity.positive?
    end
  end
end
