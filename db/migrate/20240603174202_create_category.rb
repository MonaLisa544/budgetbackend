class CreateCategory < ActiveRecord::Migration[7.0]
    def change
      create_table :categories do |t|
        t.string :name, default: ''
        t.boolean :delete_flag, default: false
  
        t.timestamps
      end
    end
  end
  
  