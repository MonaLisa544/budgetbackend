class TransactionSerializer
    include FastJsonapi::ObjectSerializer
    attributes :transaction_name, :transaction_amount, :transaction_date, :description
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
      attribute :category_name do |transaction|
        transaction.category&.category_name
      end
    
      attribute :category_icon do |transaction|
        transaction.category&.icon
      end
    
      attribute :category_icon_color do |transaction|
        transaction.category&.icon_color
      end
    belongs_to :user
    belongs_to :wallet
    belongs_to :category
end
