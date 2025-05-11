class MakeSourcePolymorphicNullableInTransactions < ActiveRecord::Migration[7.0]
  def change
    change_column_null :transactions, :source_type, true
    change_column_null :transactions, :source_id, true
  end
end
