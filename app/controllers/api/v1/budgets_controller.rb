class Api::V1::BudgetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_budget, only: [:show, :update, :destroy]

  # GET /api/v1/budgets
  def index
    if current_user.role == 1 && current_user.family_id.present?
      wallet_ids = Wallet.where(owner_type: ['User', 'Family'], owner_id: [current_user.id, current_user.family_id]).pluck(:id)
    else
      wallet_ids = [current_user.wallet.id]
    end

    budgets = Budget.where(wallet_id: wallet_ids)
    render json: BudgetSerializer.new(budgets).serializable_hash.to_json
  end

  # GET /api/v1/budgets/:id
  def show
    render json: BudgetSerializer.new(@budget).serializable_hash.to_json
  end

  # POST /api/v1/budgets
  def create
    budget_data = budget_params.except(:type)

     Rails.logger.info "Current User Role: #{current_user.role} (User ID: #{current_user.id})"
  
    wallet =
      if params[:budget][:type] == "family"
        if current_user.family_id && current_user.admin?
          Wallet.find_by(owner_type: "Family", owner_id: current_user.family_id)
        else
          return render json: { error: "No permission to use family wallet" }, status: :forbidden
        end
      else
        current_user.wallet
      end
  
    return render json: { error: "Wallet not found" }, status: :not_found unless wallet
  
    budget = Budget.new(budget_data.merge(wallet_id: wallet.id))
  
    if budget.save
      render json: BudgetSerializer.new(budget).serializable_hash.to_json, status: :created
    else
      render json: { errors: budget.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/budgets/:id
  def update
    unless authorized_to_edit?(@budget)
      return render json: { error: "No permission to update" }, status: :forbidden
    end

    if @budget.update(budget_params)
      render json: BudgetSerializer.new(@budget).serializable_hash.to_json
    else
      render json: { errors: @budget.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/budgets/:id
  def destroy
    unless authorized_to_edit?(@budget)
      return render json: { error: "No permission to delete" }, status: :forbidden
    end

    @budget.destroy
    head :no_content
  end

  private

  def set_budget
    @budget = Budget.find(params[:id])

    unless authorized_to_view?(@budget)
      render json: { error: "Access denied" }, status: :forbidden
    end
  end

  def budget_params
    params.require(:budget).permit(
      :wallet_id,
      :category_id,
      :budget_name,
      :amount,
      :start_date,
      :due_date,
      :pay_due_date,
      :status,
      :description
    )
  end

  def authorized_to_view?(budget)
    owner = budget.wallet.owner
    case budget.wallet.owner_type
    when "User"
      owner.id == current_user.id
    when "Family"
      current_user.family_id == owner.id
    else
      false
    end
  end

  def authorized_to_edit?(budget)
    owner = budget.wallet.owner

    case budget.wallet.owner_type
    when "User"
      owner.id == current_user.id
    when "Family"
      current_user.family_id == owner.id && current_user.admin?
    else
      false
    end
  end

  def authorized_to_create?(wallet_id)
    wallet = Wallet.find_by(id: wallet_id)
    return false unless wallet

    case wallet.owner_type
    when "User"
      wallet.owner_id == current_user.id
    when "Family"
      current_user.family_id == wallet.owner_id && current_user.admin?
    else
      false
    end
  end
end
