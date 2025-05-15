class Api::V1::GoalsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_goal, only: [:show, :update, :destroy]
  
    # GET /api/v1/goals
    def index
      if current_user.role == "admin" && current_user.family_id.present?
        wallet_ids = Wallet.where(owner_type: ['User', 'Family'], owner_id: [current_user.id, current_user.family_id]).pluck(:id)
      else
        wallet_ids = [current_user.wallet.id]
      end
  
      goals = Goal.where(wallet_id: wallet_ids)
      render json: GoalSerializer.new(goals).serializable_hash.to_json
    end
  
    # GET /api/v1/goals/:id
    def show
      render json: GoalSerializer.new(@goal).serializable_hash.to_json
    end
  
    # POST /api/v1/goals
    def create
      goal_data = goal_params.except(:wallet_type)
    
      wallet =
        case goal_params[:wallet_type]
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
    
      target_amount = goal_params[:target_amount].to_f
      expected_date = Date.parse(goal_params[:expected_date]) rescue nil
      start_date = goal_params[:start_date].present? ? Date.parse(goal_params[:start_date]) : Date.today
      starting_amount = goal_params[:starting_amount].to_f rescue 0.0  # 🆕 шинэчлэх
    
      if target_amount <= 0 || expected_date.nil?
        return render json: { error: "Invalid target amount or expected date" }, status: :unprocessable_entity
      end
    
      total_months = (expected_date.year * 12 + expected_date.month) - (start_date.year * 12 + start_date.month)
      total_months = [total_months, 1].max
    
      monthly_payment = if goal_params[:monthly_payment_amount].present?
                          goal_params[:monthly_payment_amount].to_f
                        else
                          ((target_amount - starting_amount) / total_months).ceil  # 🆕 автоматаар эхний мөнгө хасна
                        end
    
      goal = Goal.new(goal_data.merge(
        wallet_id: wallet.id,
        start_date: start_date,
        monthly_due_amount: monthly_payment,
        saved_amount: starting_amount # 🆕 эхлэх хадгалсан мөнгө
      ))
    
      if goal.save
        render json: GoalSerializer.new(goal).serializable_hash.to_json, status: :created
      else
        render json: { errors: goal.errors.full_messages }, status: :unprocessable_entity
      end
    end
    # PUT /api/v1/goals/:id
    def update
      unless authorized_to_edit?(@goal)
        return render json: { error: "No permission to update" }, status: :forbidden
      end
  
      if @goal.update(goal_params)
        render json: GoalSerializer.new(@goal).serializable_hash.to_json
      else
        render json: { errors: @goal.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    # DELETE /api/v1/goals/:id
    def destroy
      unless authorized_to_edit?(@goal)
        return render json: { error: "No permission to delete" }, status: :forbidden
      end
  
      @goal.destroy
      head :no_content
    end
  
    private
  
    def set_goal
      @goal = Goal.find(params[:id])
  
      unless authorized_to_view?(@goal)
        render json: { error: "Access denied" }, status: :forbidden
      end
    end
  
    def goal_params
      params.require(:goal).permit(
        :wallet_type,
        :goal_name,
        :goal_type,
        :target_amount,
        :start_date,
        :expected_date,
        :monthly_due_day,
        :description,
        :status
      )
    end
  
    def authorized_to_view?(goal)
      owner = goal.wallet.owner
  
      case goal.wallet.owner_type
      when "User"
        owner.id == current_user.id
      when "Family"
        current_user.family_id == owner.id
      else
        false
      end
    end
  
    def authorized_to_edit?(goal)
      owner = goal.wallet.owner
  
      case goal.wallet.owner_type
      when "User"
        owner.id == current_user.id
      when "Family"
        current_user.family_id == owner.id && current_user.admin?
      else
        false
      end
    end
  end
  