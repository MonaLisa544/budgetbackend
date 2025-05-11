class CreateLoans < ActiveRecord::Migration[7.0]
  def change
    create_table :loans do |t|
      t.references :wallet, null: false, foreign_key: true

      t.string  :loan_name, null: false, limit: 50
      t.string  :loan_type, limit: 50
      t.decimal :original_amount, null: false, precision: 15, scale: 2
      t.decimal :interest_rate, precision: 5, scale: 2
      t.decimal :monthly_payment_amount, precision: 15, scale: 2
      t.integer :monthly_due_day
      t.date    :start_date, null: false
      t.date    :due_date, null: false
      t.string  :status, null: false, default: "active"
      t.string  :description, limit: 255

      t.timestamps
    end
  end
end
