class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json


  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      Category.create(name: "Цалин", transaction_type: "income", user_id: resource.id)
      Category.create(name: "Хоол хүнс", transaction_type: "expense", user_id: resource.id)
      Category.create(name: "Хувцас", transaction_type: "expense", user_id: resource.id)

      render json: {
        message: "Welcome #{resource.firstName} #{resource.lastName}!",
      }, status: 200
      UserMailer.welcome_email(resource).deliver_now
    else
      render json: {
        message: resource.errors.full_messages
      }, status: 400
    end
  end
  def sign_up(resource_name, resource)
  end

  def sign_up_params
    params.require(:user).permit(:lastName, :firstName, :email, :password, :password_confirmation)
  end
end
