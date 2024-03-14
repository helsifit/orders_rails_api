class ApplicationController < ActionController::API
  wrap_parameters false

  # GET /hels
  def hels
    render plain: Order.count.to_s
  rescue => exception
    render plain: "#{exception.class}: #{exception.message}"
  end
end
