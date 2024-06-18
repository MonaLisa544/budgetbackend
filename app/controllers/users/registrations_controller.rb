class Users::RegistrationsController < Devise::RegistrationsController

  private
  def respond_with(user, _opts={})
    if user.persisted?
      render json: {
        message: "Welcome #{user.firstName} #{user.lastName}!",
      }, status: 200
      UserMailer.welcome_email(resource).deliver_now
    else
      render json: {
        status: 400,
        message: user.errors.full_messages
      }, status: 400
    end
  end

  def sign_up_params
    params.require(:user).permit(:lastName, :firstName, :email,  :password, :password_confirmation, :uid, :provider)
  end
end
