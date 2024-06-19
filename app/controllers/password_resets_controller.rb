class PasswordResetsController < ApplicationController
  # POST /password/reset
  def create
    user = User.find_by(email: params[:email])
    if user
      token = user.signed_id(purpose: 'password_reset', expires_in: 15.minutes)
      PasswordMailer.with(user: user).reset.deliver_later
      render json: { message: 'Password reset instructions sent to your email', 'reset_password_token': token}, status: :ok
    else
      render json: { error: 'Email not found' }, status: :not_found
    end
  end
  def edit
    @user = User.find_signed!(params[:token], purpose: 'password_reset')
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    # Instead of redirecting, render an error message
    render json: { error: 'Your token has expired or is invalid. Please request a new password reset.' }, status: :unprocessable_entity
  end

  def update
    @user = User.find_signed!(params[:token], purpose: 'password_reset')
    if @user.update(password_params)
      # Render a success message instead of redirecting
      render json: { message: 'Your password was reset successfully. Please sign in.' }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    # Instead of redirecting, render an error message
    render json: { error: 'Your token has expired or is invalid. Please request a new password reset.' }, status: :unprocessable_entity
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
