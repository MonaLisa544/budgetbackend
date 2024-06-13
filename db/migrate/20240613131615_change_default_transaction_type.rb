class ChangeDefaultTransactionType < ActiveRecord::Migration[7.0]
  def change
    change_column_default :categories, :transaction_type, 'expense'
  end
end
