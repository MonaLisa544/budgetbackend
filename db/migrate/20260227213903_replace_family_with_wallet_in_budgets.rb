class ReplaceFamilyWithWalletInBudgets < ActiveRecord::Migration[7.0]
  def change
    remove_reference :budgets, :family, foreign_key: true
    add_reference :budgets, :wallet, null: false, foreign_key: true
  end
end
