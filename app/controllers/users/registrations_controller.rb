class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json


  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      Category.create(category_name: "Цалин", transaction_type: "income", user_id: resource.id, icon: 'handCoins')
      Category.create(category_name: "Хоол хүнс", transaction_type: "expense", user_id: resource.id, icon: 'soup')
      Category.create(category_name: "Хадгаламж", transaction_type: "expense", user_id: resource.id, icon: 'piggyBank')
      Category.create(category_name: "Хувцас", transaction_type: "expense", user_id: resource.id, icon: 'shirt')

      render json: {
        message: "Welcome #{resource.firstName} #{resource.lastName}!",
        token: request.env['warden-jwt_auth.token']
      }, status: 200
      UserMailer.welcome_email(resource).deliver_now
    else
      render json: {
        message: resource.errors.full_messages
      }, status: 400
    end
  end

  def sign_up_params
    params.require(:user).permit(:lastName, :firstName, :email, :password, :password_confirmation)
  end
end
