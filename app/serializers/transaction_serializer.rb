class TransactionSerializer
    include FastJsonapi::ObjectSerializer
    attributes :transaction_name, :transaction_amount, :transaction_date, :description, :frequency
    belongs_to :user
    belongs_to :category
end