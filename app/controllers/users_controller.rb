class UsersController < ApplicationController
  before_action :authenticate_user!

  def update
    user = current_user
    user.profile_photo.attach(params[:user][:profile_photo]) if params[:user][:profile_photo]

    if update_user(user, user_params)
      render json: {
        message: "Profile updated successfully",
        user: {
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
          profile_photo: user.profile_photo.attached? ? url_for(user.profile_photo) : nil
        }
      }, status: 200
    else
      render json: { errors: user.errors.full_messages }, status: 400
    end
  end

  def show
    user = current_user
    render json: {
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      profile_photo: user.profile_photo.attached? ? url_for(user.profile_photo) : nil
    }
  end

  private

  def user_params
    params.require(:user).permit(:lastName, :firstName, :email, :profile_photo, :password, :password_confirmation)
  end

  def update_user(user, user_params)
    user.skip_password_validation = true
    user.update(user_params)
  end
end
