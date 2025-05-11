class AddAmountsToLoans < ActiveRecord::Migration[7.0]
  def change
    add_column :loans, :total_amount_due, :decimal, precision: 15, scale: 2, default: 0, null: false
    add_column :loans, :paid_amount, :integer, default: 0, null: false
  end
end
