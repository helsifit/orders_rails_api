module Utils
  def self.user_facing_error_message(exception)
    case exception
    when OrderValidator::ValidationError
      "Sorry, we cannot process the order: #{exception.message}"
    else
      "Unexpected error"
    end
  end

  def self.token_param_correct_format?(token_param)
    token_param.is_a?(String) && token_param.size == 36
  end
end
