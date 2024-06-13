class UsersController < ApplicationController
  before_action :authenticate_user!

  def update
    user = current_user
    user.profile_photo.attach(params[:user][:profile_photo]) if params[:user][:profile_photo]

    if update_user(user, user_params)
      render json: { message: "Profile updated successfully" }, status: 200
    else
      render json: { errors: user.errors.full_messages }, status: 400
    end
  end

  def show
    user = current_user
    if user.image.attached?
      render json: user.as_json.merge( profile_photo: url_for(user.profile_photo))
    else
      render json: user
    end


  end

  private

  def user_params
    params.require(:user).permit(:lastName, :firstName, :profile_photo, :password, :password_confirmation)
  end

  def update_user(user, user_params)
    user.skip_password_validation = true
    user.update(user_params)
  end
end
