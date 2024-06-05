# app/models/category.rb

class Category < ApplicationRecord
  has_many :transactions
    # Validate presence of name attribute
  validates :name, presence: true

  # Validate delete_flag to be either true or false
  attribute :delete_flag

end
