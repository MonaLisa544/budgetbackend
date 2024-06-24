class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  
  rescue_from ActionController::ParameterMissing do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: {
        message: "Welcome #{resource.firstName} #{resource.lastName}!",
      }, status: :ok
      UserMailer.welcome_email(resource).deliver_now
    else
      render json: {
        status: :bad_request,
        message: resource.errors.full_messages
      }, status: :bad_request
    end
  end

  def sign_up_params
    params.require(:user).permit(:lastName, :firstName, :email, :password, :password_confirmation)
  end
end

