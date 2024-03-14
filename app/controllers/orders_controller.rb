class OrdersController < ApplicationController
  wrap_parameters false

  # POST /orders
  def create
    order, line_items = OrderCreator.call(order_params)

    if order.stripe?
      session = StripeSession.create(order, line_items)
      redirect_to session.url, allow_other_host: true, status: 303
    else
      render json: {id: order.id, country_code: order.country_code, currency: order.currency, total_amount: order.total_amount,
                    line_items: order.line_items.map { |li| {product_variant_key: li.product_variant_key, unit_amount: li.unit_amount, quantity: li.quantity} }}, status: :created
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.warn(e.full_message)
    redirect_to SHOP_URL + "/error.html?error=#{CGI.escape(e.record.errors.full_messages[0])}", allow_other_host: true, status: 303
  rescue => e
    Rails.logger.warn(e.full_message)
    redirect_to SHOP_URL + "/error.html?error=Unexpected+error", allow_other_host: true, status: 303
  end

  # GET /orders/success?t=:token
  def success
    Order.find_by(token: params[:t], canceled: false, paid: false)&.update(paid: true, updated_at: Time.now.utc) if params[:t].is_a?(String) && params[:t].size == 36

    redirect_to SHOP_URL + "/success.html", allow_other_host: true, status: 303
  end

  # GET /orders/cancel?t=:token
  def cancel
    Order.find_by(token: params[:t], canceled: false, paid: false)&.update(canceled: true, updated_at: Time.now.utc) if params[:t].is_a?(String) && params[:t].size == 36

    redirect_to SHOP_URL + "/cancel.html", allow_other_host: true, status: 303
  end

  private

  # Only allow a list of trusted parameters through.
  def order_params
    params.require(:order).permit(:psp, :country_code, :email, :first_name, :last_name, :address1, :address2, :city, :zone, :postal_code, :currency, line_items: %i[product_variant unit_amount quantity])
  end
end
