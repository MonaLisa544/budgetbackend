class UsersController < ApplicationController
  before_action :authenticate_user!

  def update
    user = current_user
    user.profile_photo.attach(params[:user][:profile_photo]) if params[:user][:profile_photo]

    if update_user(user, user_params)
      render json: {
        message: "Profile updated successfully",
        user: user_response(user)
      }, status: 200
    else
      render json: { errors: user.errors.full_messages }, status: 400
    end
  end

  def show
    user = current_user
    attach_default_profile_photo(user) unless user.profile_photo.attached?
    render json: user_response(user)
  end

  private

  def user_params
    params.require(:user).permit(:lastName, :firstName, :email, :profile_photo, :password, :password_confirmation)
  end

  def update_user(user, user_params)
    user.skip_password_validation = true
    user.update(user_params)
  end

  def user_response(user)
    {
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      profile_photo: user.profile_photo.attached? ? url_for(user.profile_photo) : nil
    }
  end

  def attach_default_profile_photo(user)
    default_photo_path = Rails.root.join('app', 'assets', 'images', 'default_user_profile.png')
    user.profile_photo.attach(io: File.open(default_photo_path), filename: 'default_user_profile.png', content_type: 'image/png')
  end
end
