class AddCascadeToGoalMonthlyStatusGoalFk < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :goal_monthly_statuses, :goals
    add_foreign_key :goal_monthly_statuses, :goals, on_delete: :cascade
  end
end
