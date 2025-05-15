class UsersController < ApplicationController
  before_action :authenticate_user!

  def update
    @user = current_user
  
    if params[:profile_photo].present?
      @user.profile_photo.attach(params[:profile_photo])
    end
  
    if @user.update(user_params)
      render json: UserSerializer.new(@user).serialized_json
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def show
    @user = current_user
    attach_default_profile_photo(@user) unless @user.profile_photo.attached?
  
    render json: UserSerializer.new(@user).serialized_json
  end

  def password_change
    @user = current_user

    unless @user.valid_password?(params[:current_password])
      return render json: { error: 'Одоогийн нууц үг буруу байна' }, status: :unprocessable_entity
    end

    if params[:new_password].blank? || params[:new_password_confirmation].blank?
      return render json: { error: 'Шинэ нууц үг бөглөөгүй байна' }, status: :unprocessable_entity
    end

    if params[:new_password] != params[:new_password_confirmation]
      return render json: { error: 'Шинэ нууц үг таарахгүй байна' }, status: :unprocessable_entity
    end

    if @user.update(password: params[:new_password], password_confirmation: params[:new_password_confirmation])
      render json: { message: 'Нууц үг амжилттай солигдлоо' }, status: :ok
    else
      render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  def update_player_id
    if current_user.update(player_id: params[:player_id])
      render json: { success: true }
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private

  def user_params
    params.require(:user).permit(:firstName, :lastName, :email, :password, :password_confirmation)
  end

  def attach_default_profile_photo(user)
    default_photo_path = Rails.root.join('app', 'assets', 'images', 'default_user_profile.png')
    user.profile_photo.attach(io: File.open(default_photo_path), filename: 'default_user_profile.png', content_type: 'image/png')
  end
end
