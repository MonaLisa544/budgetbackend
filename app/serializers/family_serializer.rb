class FamilySerializer
    include FastJsonapi::ObjectSerializer
    attributes :family_name
    belongs_to :wallet
end
