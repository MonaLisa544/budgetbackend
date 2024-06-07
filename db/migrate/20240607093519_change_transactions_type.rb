class ChangeTransactionsType < ActiveRecord::Migration[7.0]
    def change 
        change_column :transactions, :transaction_type, :string, default: 'ex'
    end

end