class ApplicationController < ActionController::API
  wrap_parameters false

  # GET /hels
  def hels
    render plain: Order.count.to_s
  rescue => e
    render plain: "#{e.class}: #{e.message}"
  end
end
