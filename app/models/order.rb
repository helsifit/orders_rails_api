class Order < ApplicationRecord
  CURRENCIES = %w[USD GBP AUD CAD EUR NZD].freeze
  STRIPE = "stripe"
  attribute :token, default: -> { SecureRandom.uuid }
  has_many :line_items

  validates_presence_of :psp, :country_code, :first_name, :last_name, :address1, :city, :postal_code, on: :create
  validates_inclusion_of :currency, in: CURRENCIES, message: "cannot be used at this moment", on: :create
  validates_presence_of :zome, if: :us?, on: :create

  scope :pending, -> { where(paid: false, canceled: false) }

  def us?
    country_code == "US"
  end

  def mark_paid!
    update_columns(paid: true, updated_at: Time.now.utc)
  end

  def mark_canceled!
    update_columns(canceled: true, updated_at: Time.now.utc)
  end
end
