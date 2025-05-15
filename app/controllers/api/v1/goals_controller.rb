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
      goal_data = goal_params.except(:type)
  
      wallet =
        if params[:goal][:type] == "family"
          if current_user.family_id && current_user.admin?
            Wallet.find_by(owner_type: "Family", owner_id: current_user.family_id)
          else
            return render json: { error: "No permission to use family wallet" }, status: :forbidden
          end
        else
          current_user.wallet
        end
  
      return render json: { error: "Wallet not found" }, status: :not_found unless wallet
  
      goal = Goal.new(goal_data.merge(wallet_id: wallet.id))
  
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
        :wallet_id,
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
  