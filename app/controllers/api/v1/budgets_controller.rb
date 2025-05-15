class Api::V1::BudgetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_budget, only: [:show, :update, :destroy]

  # GET /api/v1/budgets
  def index
    if current_user.family_id.present?
      wallet_ids = Wallet.where(owner_type: ['User', 'Family'], owner_id: [current_user.id, current_user.family_id]).pluck(:id)
    else
      wallet_ids = [current_user.wallet.id]
    end
  
    budgets = Budget.where(wallet_id: wallet_ids, delete_flag: false)
  
    if params[:year].present? && params[:month].present?
      year = params[:year].to_s
      month = params[:month].to_s.rjust(2, '0')
      target_month = "#{year}-#{month}"
  
      # ✅ Зөв сар, жилтэй monthly_budget байгаа Budget-уудыг шүүнэ
      budgets = budgets.joins(:monthly_budgets).where(monthly_budgets: { month: target_month })
    end
  
    render json: BudgetSerializer.new(budgets.distinct, params: { year: params[:year], month: params[:month] }).serialized_json
  end

  # POST /api/v1/budgets
  def create
    budget_data = budget_params.except(:wallet_type)
  
    wallet =
      case budget_params[:wallet_type]
      when "family"
        if current_user.family_id && current_user.admin?
          Wallet.find_by(owner_type: "Family", owner_id: current_user.family_id)
        else
          return render json: { error: "No permission to use family wallet" }, status: :forbidden
        end
      when "private"
        current_user.wallet
      else
        return render json: { error: "Invalid wallet type" }, status: :unprocessable_entity
      end
  
    return render json: { error: "Wallet not found" }, status: :not_found unless wallet
  
    # ➡️ Энэ wallet дотор category давхардаагүй эсэхийг шалгана
    existing_budget = Budget.where(wallet_id: wallet.id, category_id: budget_data[:category_id], delete_flag: false).first
    if existing_budget.present?
      return render json: { error: "This category already exists in this wallet." }, status: :unprocessable_entity
    end
  
    # ➡️ Transaction эхэлж байна
    Budget.transaction do
      budget = Budget.new(budget_data.merge(wallet_id: wallet.id))
  
      if budget.save
        MonthlyBudget.create!(
          budget_id: budget.id,
          month: Date.today.strftime("%Y-%m"),
          amount: budget.amount,
          used_amount: 0
        )
        render json: BudgetSerializer.new(budget).serialized_json, status: :created
      else
        raise ActiveRecord::Rollback, "Budget save failed"
      end
    end
  rescue => e
    Rails.logger.error("Budget creation failed: #{e.message}")
    render json: { errors: ["Failed to create budget"] }, status: :unprocessable_entity
  end
  

  # PUT/PATCH /api/v1/budgets/:id
  # PUT/PATCH /api/v1/budgets/:id
def update
  unless authorized_to_edit?(@budget)
    return render json: { error: "No permission to update" }, status: :forbidden
  end

  wallet = @budget.wallet
  success = false

  Budget.transaction do
    if budget_params[:category_id] && budget_params[:category_id] != @budget.category_id
      existing_budget = Budget.where(wallet_id: wallet.id, category_id: budget_params[:category_id], delete_flag: false).where.not(id: @budget.id).first
      if existing_budget.present?
        raise ActiveRecord::Rollback, "This category already exists in this wallet."
      end
    end

    if @budget.update(budget_params.except(:wallet_type))
      # ✅ Тухайн сарын MonthlyBudget-ийг шинэчилнэ
      current_month = Date.today.strftime("%Y-%m")
      monthly_budget = MonthlyBudget.find_by(budget_id: @budget.id, month: current_month)
      monthly_budget.update!(amount: @budget.amount) if monthly_budget

      success = true
    else
      raise ActiveRecord::Rollback, "Failed to update budget"
    end
  end

  if success
    render json: BudgetSerializer.new(@budget).serialized_json
  else
    render json: { errors: ["Failed to update budget"] }, status: :unprocessable_entity
  end
end

  # DELETE /api/v1/budgets/:id
  def destroy
    unless authorized_to_edit?(@budget)
      return render json: { error: "No permission to delete" }, status: :forbidden
    end

    @budget.update!(delete_flag: true)
    head :no_content
  end

  private

  def set_budget
    @budget = Budget.find_by(id: params[:id], delete_flag: false)
  
    unless @budget
      render json: { error: "Budget not found" }, status: :not_found
      return
    end
  
    unless authorized_to_view?(@budget)
      render json: { error: "Access denied" }, status: :forbidden
    end
  end

  def budget_params
    params.require(:budget).permit(:wallet_type, :category_id, :budget_name, :amount, :pay_due_date, :description)
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
end
