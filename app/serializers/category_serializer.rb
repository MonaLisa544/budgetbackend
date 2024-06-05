class CategorySerializer
    include FastJsonapi::ObjectSerializer
    attributes :name, :delete_flag
    has_many :transactions
end