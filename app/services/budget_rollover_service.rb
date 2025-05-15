class BudgetRolloverService
    def self.rollover_monthly_budgets
      Wallet.find_each do |wallet|
        wallet.budgets.where('due_date < ?', Date.today).each do |old_budget|
          start_date = Date.today.beginning_of_month
          due_date = Date.today.end_of_month
  
          existing = Budget.find_by(wallet_id: wallet.id, category_id: old_budget.category_id, start_date: start_date)
  
          unless existing
            Budget.create!(
              wallet_id: wallet.id,
              category_id: old_budget.category_id,
              amount: old_budget.amount, 
              used_amount: 0,
              start_date: start_date,
              due_date: due_date,
              budget_name: old_budget.budget_name, # ✨ ШИНЭ нэмэлт
              description: old_budget.description, # ✨ нэмэлт, optional
              status: old_budget.status || "active", # ✨ нэмэлт, optional
              delete_flag: false # ✨ нэмэлт, default
            )
          end
        end
      end
    end
  end