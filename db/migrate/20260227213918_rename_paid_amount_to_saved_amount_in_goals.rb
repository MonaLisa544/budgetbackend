class RenamePaidAmountToSavedAmountInGoals < ActiveRecord::Migration[7.0]
  def change
    rename_column :goals, :paid_amount, :saved_amount
  end
end
