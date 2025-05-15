class MonthlyBudgetAutoCreateService
  def self.create_for_all_budgets
    today = Date.today
    target_month = today.strftime("%Y-%m")

    Budget.where(delete_flag: false).find_each do |budget|
      unless MonthlyBudget.exists?(budget_id: budget.id, month: target_month)
        MonthlyBudget.create!(
          budget_id: budget.id,
          month: target_month,
          amount: budget.amount,
          used_amount: 0
        )
      end
    end
  end
end
