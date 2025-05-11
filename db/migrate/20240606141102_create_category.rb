class CreateCategory < ActiveRecord::Migration[7.0]
    def change
      create_table :categories do |t|
        t.string :category_name, default: ''
        t.string :icon, default: ''
        t.string :icon_color, default: '#FF2196F3'
        t.string :transaction_type, default: 'expense'
        t.boolean :delete_flag, default: false
        t.references :user, null: false, foreign_key: {to_table: :users}
  
        t.timestamps
      end
    end
  end
  
  