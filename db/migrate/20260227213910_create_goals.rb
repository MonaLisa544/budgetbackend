class CreateGoals < ActiveRecord::Migration[7.0]
  def change
    create_table :goals do |t|
      t.references :wallet, null: false, foreign_key: true

      t.string :goal_name, null: false, limit: 50
      t.decimal :target_amount, null: false, precision: 12, scale: 2

      t.string :goal_type, null: false # saving, loan
      t.string :status, default: "active" # active, completed

      t.decimal :paid_amount, default: 0, precision: 12, scale: 2, null: false
      t.decimal :remaining_amount, default: 0, precision: 12, scale: 2, null: false

      t.date :start_date, null: false
      t.date :expected_date, null: false
      t.integer :monthly_due_day, null: false

      t.string :description, limit: 255

      t.timestamps
    end
  end
end