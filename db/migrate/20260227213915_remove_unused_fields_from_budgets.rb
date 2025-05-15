class RemoveUnusedFieldsFromBudgets < ActiveRecord::Migration[7.0]
  def change
    remove_column :budgets, :start_date, :date
    remove_column :budgets, :due_date, :date
    remove_column :budgets, :status, :string
    remove_column :budgets, :used_amount, :integer
  end
end
