class BudgetSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :budget_name, :amount, :pay_due_date, :description

  belongs_to :wallet
  belongs_to :category

  attribute :wallet_type do |budget|
    case budget.wallet.owner_type
    when "User"
      "private"
    when "Family"
      "family"
    else
      "unknown"
    end
  end
  attribute :category_name do |budget|
    budget.category&.category_name
  end

  attribute :category_icon do |budget|
    budget.category&.icon
  end

  attribute :category_icon_color do |budget|
    budget.category&.icon_color
  end

  has_many :monthly_budgets, serializer: MonthlyBudgetSerializer

  # Одоогийн сарын monthly budget харах
  attribute :current_month_budget do |object, params|
    if params[:year].present? && params[:month].present?
      year = params[:year].to_s
      month = params[:month].to_s.rjust(2, '0') # 🎯 сарын урд 0 нэмэх
      target_month = "#{year}-#{month}"
    else
      target_month = Date.today.strftime("%Y-%m")
    end
  
    monthly_budget = object.monthly_budgets.find { |mb| mb.month == target_month }
  
    if monthly_budget
      {
        id: monthly_budget.id,
        month: monthly_budget.month,
        amount: monthly_budget.amount,
        used_amount: monthly_budget.used_amount,
        remaining_amount: monthly_budget.remaining_amount,
        spending_status: monthly_budget.spending_status,
        timeline_status: monthly_budget.timeline_status
      }
    else
      nil
    end
  end
end
