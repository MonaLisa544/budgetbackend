class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.string :transaction_name, default: ''
      t.integer :transaction_amount, default: 0
      t.datetime :transaction_date, default: ''
      t.boolean :transaction_type, default: false 
      t.string :description, default: ''
      t.boolean :frequency, default: false
      t.boolean :delete_flag, default: false
      
      t.references :user, null: false, foreign_key: {to_table: :users}
      t.references :category, null: false, foreign_key: {to_table: :categories}

      t.timestamps
    end
  end
end