class UserSerializer
    include FastJsonapi::ObjectSerializer
    attributes :first_name, :last_name, :email, :role
    belongs_to :family
    belongs_to :wallet
  end