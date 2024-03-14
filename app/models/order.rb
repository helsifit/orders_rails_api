class Order < ApplicationRecord
  CURRENCIES = %w[USD GBP AUD CAD EUR NZD].freeze
  STRIPE = "stripe"
  attribute :token, default: -> { SecureRandom.uuid }
  has_many :line_items
  scope :pending, -> { where(paid: false, canceled: false) }

  def mark_paid!
    update_columns(paid: true, updated_at: Time.now.utc)
  end

  def mark_canceled!
    update_columns(canceled: true, updated_at: Time.now.utc)
  end
end
