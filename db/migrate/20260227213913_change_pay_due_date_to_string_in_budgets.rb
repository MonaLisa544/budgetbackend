class ChangePayDueDateToStringInBudgets < ActiveRecord::Migration[7.0]
  def change
    change_column :budgets, :pay_due_date, :int
  end
end
