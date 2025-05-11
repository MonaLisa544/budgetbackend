class AddFieldsToUsers < ActiveRecord::Migration[7.0]
    def change
      add_reference :users, :family, foreign_key: true
      add_column :users, :role, :integer, null: false, default: 0
    end
  end
