class OrdersController < ApplicationController
  wrap_parameters false
  rescue_from StandardError do |exception|
    Rails.logger.warn(exception.full_message)
    redirect_to SHOP_URL + "/error.html?error=#{CGI.escape(Utils.user_facing_error_message(exception))}", allow_other_host: true, status: 303
  end

  # POST /orders
  def create
    order, line_items = OrderCreator.call(order_params)
    payment_session_url = PaymentInitiator.call(order, line_items)

    redirect_to payment_session_url, allow_other_host: true, status: 303
  end

  # GET /orders/success?t=:token
  def success
    if Utils.token_param_correct_format?(params[:t])
      Order.pending.find_by(token: params[:t])&.mark_paid!
    end
    redirect_to SHOP_URL + "/success.html", allow_other_host: true, status: 303
  end

  # GET /orders/cancel?t=:token
  def cancel
    if Utils.token_param_correct_format?(params[:t])
      Order.pending.find_by(token: params[:t])&.mark_canceled!
    end
    redirect_to SHOP_URL + "/cancel.html", allow_other_host: true, status: 303
  end

  private

  # Only allow a list of trusted parameters through.
  def order_params
    params.require(:order).permit(:psp, :currency, :country_code, :email, :first_name, :last_name, :address1, :address2, :city, :zone, :postal_code, line_items: %i[product_variant unit_amount quantity])
  end
end
