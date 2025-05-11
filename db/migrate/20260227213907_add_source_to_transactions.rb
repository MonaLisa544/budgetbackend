class AddSourceToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_reference :transactions, :source, polymorphic: true, null: false
  end
end
