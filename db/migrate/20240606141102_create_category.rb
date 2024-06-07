class CreateCategory < ActiveRecord::Migration[7.0]
    def change
      create_table :categories do |t|
        t.string :name, default: ''
        t.string :icon, default: ''
        t.string :transaction_type, default: 'ex'
        t.boolean :delete_flag, default: false
        t.references :user, null: false, foreign_key: {to_table: :users}
  
        t.timestamps
      end
    end
  end
  
  