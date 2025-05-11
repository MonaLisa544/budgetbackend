class CategorySerializer
    include FastJsonapi::ObjectSerializer
    attributes :category_name, :icon, :icon_color, :transaction_type
    belongs_to :user
end
