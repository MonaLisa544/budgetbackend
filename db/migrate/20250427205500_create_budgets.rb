class CreateBudgets < ActiveRecord::Migration[7.0]
    def change
      create_table :budgets do |t|
        t.string :budget_name, null: false
        t.integer :amount, null: false
        t.date :start_date, null: false
        t.date :due_date, null: false
        t.date :pay_due_date
        t.string :status, null: false, default: "active"
        t.text :description
        t.boolean :delete_flag, default: false
  
        t.references :family, null: false, foreign_key: true
        t.references :category, null: false, foreign_key: true
  
        t.timestamps
      end
    end
  end