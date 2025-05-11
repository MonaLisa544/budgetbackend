class CreateWallets < ActiveRecord::Migration[7.0]
    def change
      create_table :wallets do |t|
        t.integer :balance, default: 0, null: false
        t.boolean :delete_flag, default: false
        t.references :owner, polymorphic: true, index: true

        t.timestamps
      end
    end
  end
  