# app/models/category.rb

class Category < ApplicationRecord
  has_many :transactions
  belongs_to :user
    # Validate presence of name attribute
  validates :name, presence: true
  validates :icon, presence: true
  enum :transaction_type, { Expences: 'ex', Income: 'in' }

  # Validate delete_flag to be either true or false
  attribute :delete_flag

end
