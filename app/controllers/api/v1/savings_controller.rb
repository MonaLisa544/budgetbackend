class Api::V1::SavingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_saving, only: [:show, :update, :destroy]

  # GET /api/v1/savings
  def index
    wallet_ids =
      if current_user.role == 1 && current_user.family_id.present?
        Wallet.where(owner_type: ['User', 'Family'], owner_id: [current_user.id, current_user.family_id]).pluck(:id)
      else
        [current_user.wallet.id]
      end

    savings = Saving.where(wallet_id: wallet_ids)
    render json: SavingSerializer.new(savings).serializable_hash.to_json
  end

  # GET /api/v1/savings/:id
  def show
    render json: SavingSerializer.new(@saving).serializable_hash.to_json
  end

  # POST /api/v1/savings
  def create
    saving_data = saving_params.except(:type)

    wallet =
      if params[:saving][:type] == "family"
        if current_user.family_id && current_user.admin?
          Wallet.find_by(owner_type: "Family", owner_id: current_user.family_id)
        else
          return render json: { error: "No permission to use family wallet" }, status: :forbidden
        end
      else
        current_user.wallet
      end

    return render json: { error: "Wallet not found" }, status: :not_found unless wallet

    saving = Saving.new(saving_data.merge(wallet_id: wallet.id))

    if saving.save
      render json: SavingSerializer.new(saving).serializable_hash.to_json, status: :created
    else
      render json: { errors: saving.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/savings/:id
  def update
    unless authorized_to_edit?(@saving)
      return render json: { error: "No permission to update" }, status: :forbidden
    end

    if @saving.update(saving_params)
      render json: SavingSerializer.new(@saving).serializable_hash.to_json
    else
      render json: { errors: @saving.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/savings/:id
  def destroy
    unless authorized_to_edit?(@saving)
      return render json: { error: "No permission to delete" }, status: :forbidden
    end

    @saving.destroy
    head :no_content
  end

  private

  def set_saving
    @saving = Saving.find(params[:id])
    unless authorized_to_view?(@saving)
      render json: { error: "Access denied" }, status: :forbidden
    end
  end

  def saving_params
    params.require(:saving).permit(
      :wallet_id,
      :saving_name,
      :target_amount,
      :start_date,
      :expected_date,
      :status,
      :description
    )
  end

  def authorized_to_view?(saving)
    owner = saving.wallet.owner
    case saving.wallet.owner_type
    when "User"
      owner.id == current_user.id
    when "Family"
      current_user.family_id == owner.id
    else
      false
    end
  end

  def authorized_to_edit?(saving)
    owner = saving.wallet.owner
    case saving.wallet.owner_type
    when "User"
      owner.id == current_user.id
    when "Family"
      current_user.family_id == owner.id && current_user.admin?
    else
      false
    end
  end
end
