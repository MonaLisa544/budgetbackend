class Api::V1::FamiliesController < ApplicationController
  before_action :authenticate_user!

  def me
    @family = current_user.family
  
    unless @family
      return render json: { error: "Та ямар нэгэн гэр бүлд харьяалагдаагүй байна" }, status: :not_found
    end
  
    render json: FamilySerializer.new(@family).serialized_json, status: :ok
  end
  

  # POST /api/v1/families
  def create
    @family = Family.new(family_params)
  
    if @family.save
      current_user.update(family_id: @family.id, role: 1)
      render json: FamilySerializer.new(@family).serialized_json, status: :created
    else
      render json: { errors: @family.errors.full_messages }, status: :unprocessable_entity
    end
  end

    # GET /api/v1/families/members
    def members
      family = current_user.family
    
      unless family
        return render json: { error: "Та ямар нэгэн гэр бүлд харьяалагдаагүй байна" }, status: :not_found
      end
    
      members = family.users
    
      render json: UserSerializer.new(members).serialized_json, status: :ok
    end

  

  # POST /api/v1/families/join
  def join
    family_data = params.require(:family).permit(:family_name, :password)
    family = Family.find_by(family_name: family_data[:family_name])
  
    if family&.authenticate(family_data[:password])
      current_user.update(family_id: family.id, role: 2)
      render json: FamilySerializer.new(family).serialized_json, status: :ok
    else
      render json: { error: "Гэр бүл олдсонгүй эсвэл нууц үг буруу" }, status: :unauthorized
    end
  end

   # PATCH /api/v1/families/change_role
   def change_role
    Rails.logger.debug "CURRENT USER ROLE (enum): #{current_user.role}"
    Rails.logger.debug "CURRENT USER ROLE (int): #{User.roles[current_user.role]}"
    Rails.logger.debug "CURRENT USER ID: #{current_user.id}"

  
    unless User.roles[current_user.role] == 1
      return render json: { error: "Та эрхгүй байна" }, status: :forbidden
    end
  
    role_params = params.permit(:user_id, :role)
    user = User.find_by(id: role_params[:user_id], family_id: current_user.family_id)
  
    unless user
      return render json: { error: "Хэрэглэгч олдсонгүй эсвэл таны гэр бүлд хамааралгүй" }, status: :not_found
    end
  
    new_role = role_params[:role].to_i
    unless User.roles.values.include?(new_role)
      return render json: { error: "Зөвшөөрөгдөөгүй role" }, status: :unprocessable_entity
    end
  
    if user.update(role: User.roles.key(new_role))
      render json: { message: "Role амжилттай солигдлоо", user_id: user.id, role: user.role }, status: :ok
    else
      render json: { error: "Өөрчлөлт хийхэд алдаа гарлаа" }, status: :unprocessable_entity
    end
  end
  


  private

  def family_params
    params.require(:family).permit(:family_name, :password)
  end
end
