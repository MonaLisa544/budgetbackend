class Api::V1::GoalsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_goal, only: [:show, :update, :destroy, :monthly_statuses]

  # GET /api/v1/goals
  def index
    goals = Goal.where(wallet_id: available_wallet_ids)
    render json: GoalSerializer.new(goals).serializable_hash.to_json
  end

  # GET /api/v1/goals/:id
  def show
    render json: GoalSerializer.new(@goal).serializable_hash.to_json
  end

  # POST /api/v1/goals
  def create
    goal_data = goal_params.except(:wallet_type, :starting_amount)
    wallet = find_wallet(goal_params[:wallet_type])
    return render json: { error: "Wallet not found" }, status: :not_found unless wallet

    target_amount   = goal_params[:target_amount].to_f
    start_date      = goal_params[:start_date].present? ? Date.parse(goal_params[:start_date]) : Date.today
    expected_date   = Date.parse(goal_params[:expected_date]) rescue nil
    starting_amount = goal_params[:starting_amount].to_f rescue 0.0

    if target_amount <= 0 || expected_date.nil?
      return render json: { error: "Invalid target amount or expected date" }, status: :unprocessable_entity
    end

    if expected_date < Date.today
      return render json: { error: "Expected date must be in the future" }, status: :unprocessable_entity
    end

    months = ((expected_date.year * 12 + expected_date.month) - (start_date.year * 12 + start_date.month)).clamp(1, Float::INFINITY)

    monthly_due_amount = if goal_params[:monthly_due_amount].present?
      goal_params[:monthly_due_amount].to_f
    else
      GoalCalculatorService.calculate_monthly_due_amount(
        target_amount: target_amount,
        starting_amount: starting_amount,
        start_date: start_date,
        expected_date: expected_date
      )
    end

    goal = Goal.new(goal_data.merge(
      wallet_id: wallet.id,
      start_date: start_date,
      monthly_due_amount: monthly_due_amount,
      saved_amount: starting_amount
    ))

    if goal.save
      (0...months).each do |i|
        month_date = start_date >> i
        GoalMonthlyStatus.create!(
          goal: goal,
          month: "#{month_date.year}-#{month_date.month.to_s.rjust(2, '0')}",
          paid_amount: (i.zero? ? starting_amount : 0),
          status: "pending"
        )
      end

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

    update_data = goal_params.except(:wallet_type)
    now = Date.today

    # Огнооны шалгалт, ирээдүйн саруудыг зөв удирдах
    start_date = update_data[:start_date] ? Date.parse(update_data[:start_date]) : @goal.start_date
    expected_date = update_data[:expected_date] ? Date.parse(update_data[:expected_date]) : @goal.expected_date

    if expected_date < Date.today
      return render json: { error: "Expected date must be in the future" }, status: :unprocessable_entity
    end

    # Сарууд өөрчлөгдсөн бол (start_date/expected_date өөрчлөгдвөл)
    if update_data[:expected_date].present? || update_data[:start_date].present?
      # 1. Шинэ саруудын цуваа гаргаж авна
      new_months = (start_date..expected_date).map { |d| Date.new(d.year, d.month, 1) }.uniq
      future_months = new_months.select { |d| d >= Date.today.beginning_of_month }
      future_month_strs = future_months.map { |d| "#{d.year}-#{d.month.to_s.rjust(2, '0')}" }

      # 2. Ирээдүйн саруудыг зөвхөн update/устгана, өнгөрсөн сарууд paid_amount-тай бол устгахгүй
      @goal.goal_monthly_statuses.where("month >= ?", Date.today.strftime("%Y-%m")).where.not(month: future_month_strs).destroy_all

      # 3. Байхгүй шинэ саруудад шинээр мөр үүсгэнэ
      future_month_strs.each do |month_str|
        @goal.goal_monthly_statuses.find_or_create_by!(month: month_str) do |gms|
          gms.paid_amount = 0
          gms.status = "pending"
        end
      end
    end

    # monthly_due_amount дахин бодох (change хийж байгаа бол)
    if update_data[:monthly_due_amount].blank? && (
        update_data[:target_amount].present? ||
        update_data[:start_date].present? ||
        update_data[:expected_date].present? ||
        update_data[:starting_amount].present?
      )
      update_data[:monthly_due_amount] = GoalCalculatorService.calculate_monthly_due_amount(
        target_amount: (update_data[:target_amount] || @goal.target_amount).to_f,
        starting_amount: (update_data[:starting_amount] || @goal.saved_amount).to_f,
        start_date: start_date,
        expected_date: expected_date
      )
    end

    if @goal.update(update_data)
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

  # GET /api/v1/goals/:id/monthly_statuses
  def monthly_statuses
    statuses = @goal.goal_monthly_statuses.order(:month)
    render json: GoalMonthlyStatusSerializer.new(statuses).serializable_hash.to_json
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
      :monthly_due_amount,
      :starting_amount,
      :description,
      :status,
      :saved_amount, 
      :remaining_amount,     # <-- энэ 3-ыг permit-д нэм
    :months_left    
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

  def available_wallet_ids
    if current_user.family_id.present?
      Wallet.where(owner_type: ['User', 'Family'], owner_id: [current_user.id, current_user.family_id]).pluck(:id)
    else
      [current_user.wallet.id]
    end
  end

  def find_wallet(wallet_type)
    case wallet_type
    when "family"
      current_user.family_id && current_user.admin? ? Wallet.find_by(owner_type: "Family", owner_id: current_user.family_id) : nil
    when "private"
      current_user.wallet
    end
  end
end
