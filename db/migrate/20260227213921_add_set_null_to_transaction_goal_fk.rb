class AddSetNullToTransactionGoalFk < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :transactions, :goals
    add_foreign_key :transactions, :goals, on_delete: :nullify
  end
end
