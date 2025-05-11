class TransactionSerializer
    include FastJsonapi::ObjectSerializer
    attributes :transaction_name, :transaction_amount, :transaction_date, :description, :category_id
    attribute :transaction_type do |transaction|
        transaction.category.transaction_type
    end
    attribute :wallet_type do |transaction|
        case transaction.wallet.owner_type
        when "User"
          "private"
        when "Family"
          "family"
        else
          "unknown"
        end
      end
    belongs_to :user
    belongs_to :wallet
end
