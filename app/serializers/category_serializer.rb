class CategorySerializer
    include FastJsonapi::ObjectSerializer
    attributes :name, :delete_flag
    
end