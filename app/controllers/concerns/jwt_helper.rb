module JwtHelper
    extend ActiveSupport::Concern
  
    SECRET_KEY = Rails.application.secrets.secret_key_base.to_s
  
    def encode_token(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, SECRET_KEY)
    end
  
    def decode_token(token)
      decoded = JWT.decode(token, SECRET_KEY).first
      HashWithIndifferentAccess.new decoded
    rescue
      nil
    end
  
    def auth_header
      request.headers['Authorization']
    end
  
    def current_user
      return unless auth_header
  
      token = auth_header.split(' ')[1]
      decoded_token = decode_token(token)
      @current_user ||= User.find(decoded_token[:user_id]) if decoded_token
    end
  
    def logged_in?
      !!current_user
    end
  
    def authorize_request
      render json: { error: 'Unauthorized' }, status: :unauthorized unless logged_in?
    end
  end
  