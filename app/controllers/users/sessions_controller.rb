class Users::SessionsController < Devise::SessionsController
  respond_to :json
  def create
    user = User.find_by(email: params[:user][:email])

    if user && user.valid_password?(params[:user][:password])
      super
    else
      message = user.nil? ? "Not registered. Please sign up!" : "Password incorrect. Please try again!"
      render json: { message: message }, status: 401
    end
  end
  private
  def respond_with(resource, _opts = {})
    if resource
      # current_user is logged in successfully
      render json: {
        token: request.env['warden-jwt_auth.token']
      }, status: 200
    end
  end
  def respond_to_on_destroy
    begin
      Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
      render json: { message: 'Logged out' }, status: 200
    rescue JWT::DecodeError => e
      Rails.logger.error "JWT decode алдаа гарлаа: #{e.message}"
      render json: { message: 'Already logged out or invalid token' }, status: 401
    end
  end
  
end
