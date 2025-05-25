class RenameRemainingAmountToMonthlyDueAmountInGoals < ActiveRecord::Migration[7.0]
  def change
    rename_column :goals, :remaining_amount, :monthly_due_amount
  end
end
