class RenameSavedAmountToPaidAmountInGoalMonthlyStatuses < ActiveRecord::Migration[7.0]
  def change
    rename_column :goal_monthly_statuses, :saved_amount, :paid_amount
  end
end
