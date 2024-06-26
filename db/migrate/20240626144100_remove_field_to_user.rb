class RemoveFieldToUser < ActiveRecord::Migration[7.0]
    def change
      remove_column :users, :role, :integer
      remove_column :users, :provider, :string
      remove_column :users, :uid, :string
    end
  end