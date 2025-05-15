namespace :monthly_budget do
    desc "Auto create MonthlyBudgets for all active Budgets for the new month"
    task auto_create: :environment do
      puts "👉 MonthlyBudget auto create эхэлж байна..."
      MonthlyBudgetAutoCreateService.create_for_all_budgets
      puts "✅ MonthlyBudget auto create амжилттай дууслаа!"
    end
  end
  