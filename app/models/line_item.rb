class LineItem < ApplicationRecord
  belongs_to :order

  validates_presence_of :unit_amount, message: "product variant is unknown"
  validates_numericality_of :quantity, greater_than: 0, message: "must be positive"

  def subtotal_amount
    quantity * unit_amount
  end

  def product_name
    PRODUCT_VARIANTS.fetch(product_variant_key).fetch("title")
  end
end
