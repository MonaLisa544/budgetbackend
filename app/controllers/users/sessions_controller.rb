class Users::SessionsController < Devise::SessionsController
  respond_to :json
  def create
    user = User.find_by(email: params[:user][:email])

    if user && user.valid_password?(params[:user][:password])
      super
    else
      message =  if user.nil?
        "Not registered. Please sign up!"
      else
        "Password incorrect. Please try again!"
      end
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
    current_user ? log_out_success : log_out_failure
  end
  def log_out_success
    render json: { message: "Logged out." }, status: 200
  end
  def log_out_failure
    render json: { message: "Logged out failure."}, status: 401
  end
end
