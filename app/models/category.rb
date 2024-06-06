# app/models/category.rb

class Category < ApplicationRecord
  has_many :transactions
  belongs_to :user
    # Validate presence of name attribute
  validates :name, presence: true
  validates :icon, presence: true

  # Validate delete_flag to be either true or false
  attribute :delete_flag

end
