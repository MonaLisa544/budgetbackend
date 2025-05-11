class CreateNotifications < ActiveRecord::Migration[7.0]
    def change
      create_table :notifications do |t|
        t.references :user, null: false, foreign_key: true
        t.string :title, null: false
        t.text :body
        t.string :notification_type
        t.boolean :read, default: false
  
        t.timestamps
      end
    end
  end
  