class AddFieldsToTransactions < ActiveRecord::Migration[7.0]
    def change
      add_reference :transactions, :wallet, foreign_key: true
    end
  end