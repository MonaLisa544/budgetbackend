class TransactionSerializer
    include FastJsonapi::ObjectSerializer
    attributes :transaction_amount, :transaction_date, :transaction_type, :description, :frequency
    
end