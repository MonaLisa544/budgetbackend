class CreateFamilies < ActiveRecord::Migration[7.0]
    def change
      create_table :families do |t|
        t.boolean :delete_flag, default: false
        t.timestamps
      end
    end
  end