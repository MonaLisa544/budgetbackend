class CategorySerializer
    include FastJsonapi::ObjectSerializer
    attributes :name, :icon 
    has_many :transactions
    belongs_to :user
end