class CategorySerializer
    include FastJsonapi::ObjectSerializer
    attributes :name, :icon, :transaction_type
    has_many :transactions
    belongs_to :user
end