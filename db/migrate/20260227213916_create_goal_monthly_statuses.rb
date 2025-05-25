class CreateGoalMonthlyStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :goal_monthly_statuses do |t|
      t.references :goal, null: false, foreign_key: true
      t.string :month, null: false # "2025-06" гэх мэт
      t.string :status, null: false # "success" эсвэл "failed"
      t.decimal :saved_amount, precision: 15, scale: 2, default: 0.0

      t.timestamps
    end

    add_index :goal_monthly_statuses, [:goal_id, :month], unique: true # нэг сар бүр давхцахгүй
  end
end
