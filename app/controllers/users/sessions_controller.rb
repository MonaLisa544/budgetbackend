class Users::SessionsController < Devise::SessionsController
  respond_to :json
  private
  def respond_with(resource, _opts = {})
  if resource
    # current_user is logged in successfully
    render json: {
      user: current_user.as_json
    }, status: 200
  else
    # current_user is not logged in successfully
    render json: {
      messages: ["Invalid Email or Password."],
    }, status: 422
  end
  end
  def respond_to_on_destroy
    current_user ? log_out_success : log_out_failure
  end
  def log_out_success
    render json: { message: "Logged out." }, status: :ok
  end
  def log_out_failure
    render json: { message: "Logged out failure."}, status: :unauthorized
  end
end