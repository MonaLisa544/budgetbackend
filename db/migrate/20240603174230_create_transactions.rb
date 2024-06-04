class CreateTransactions < ActiveRecord::Migration[7.0]
    def change
      create_table :transations do |t|
        t.integer :transation_amount
        t.datetime :transaction_date
        t.boolean :transaction_type
        t.string :description
        t.boolean :frequency
        t.boolean :delete_flag
        
        # t.references :user, null: false, foreign_key: true
        t.references :category, null: false, foreign_key: {to_table: :categories}
  
        t.timestamps
      end
    end
  end
  