class AddGoalIdToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_reference :transactions, :goal, foreign_key: true
  end
end
