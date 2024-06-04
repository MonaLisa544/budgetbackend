# app/models/category.rb

class Category < ApplicationRecord
  has_many :transactions
    # Validate presence of name attribute
  validates :name, presence: true

  # Validate delete_flag to be either true or false
  validates :delete_flag, inclusion: { in: [true, false] }

end
