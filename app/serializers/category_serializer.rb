class CategorySerializer
    include FastJsonapi::ObjectSerializer
    attributes :name, :icon, :transaction_type
    belongs_to :user
end
