class AddPlayerIdToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :player_id, :string
  end
end
