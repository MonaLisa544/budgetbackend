class PasswordMailer < ApplicationMailer
  def reset
    @user = params[:user]
    token = @user.signed_id(purpose: 'password_reset', expires_in: 15.minutes)
    mail to: @user.email
  end
end
