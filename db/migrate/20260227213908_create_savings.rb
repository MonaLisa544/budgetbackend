class CreateSavings < ActiveRecord::Migration[7.0]
  def change
    create_table :savings do |t|
      t.references :wallet, null: false, foreign_key: true

      t.string  :saving_name, null: false, limit: 50
      t.integer :target_amount, null: false
      t.integer :paid_amount, default: 0, null: false

      t.date    :start_date, null: false
      t.date    :expected_date, null: false

      t.string  :status, default: "active", null: false
      t.string  :description, limit: 255
      t.boolean :delete_flag, default: false

      t.timestamps
    end
  end
end