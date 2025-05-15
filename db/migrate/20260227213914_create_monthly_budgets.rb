class CreateMonthlyBudgets < ActiveRecord::Migration[7.0]
  def change
    create_table :monthly_budgets do |t|
      t.references :budget, null: false, foreign_key: true
      t.string :month, null: false # Жишээ нь "2025-05"
      t.decimal :amount, default: 0
      t.decimal :used_amount, default: 0

      t.timestamps
    end

    add_index :monthly_budgets, [:budget_id, :month], unique: true
  end
end
