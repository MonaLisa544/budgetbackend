# app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  puts "ppppppppp"

  def google_oauth2
    puts "hhhhhhha"
  end

  #   if auth.credentials.nil?
  #     Rails.logger.error "Omniauth credentials are missing or nil"
  #     redirect_to new_user_session_path, alert: "Authentication failed. Please try again."
  #     return
  #   end
  #   @user = User.form_omniauth(request.env['omniauth.auth'])
  #   if @user.persisted?
  #     flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
  #     sign_in_and_redirect @user, event: :authentication
  #   else
  #     session['devise.auth_data'] = request.env['omniauth.auth'].except('extra')
  #     redirect_to new_user_registration_url, alert:@user.errors.full_messages.join("\n")
  #   end
  # end
  # def failure
  #   super
  # end
end
