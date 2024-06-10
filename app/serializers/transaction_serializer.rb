class TransactionSerializer
    include FastJsonapi::ObjectSerializer
    attributes :transaction_name, :transaction_amount, :transaction_date, :description, :frequency

    attribute :category_name do |transaction|
        transaction.category.name
    end
    belongs_to :user
    belongs_to :category
end