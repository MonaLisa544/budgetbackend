# app/models/category.rb

class Category < ApplicationRecord
  has_many :transactions
  belongs_to :user
    # Validate presence of name attribute
  validates :name, presence: true, uniqueness: true
  validates :icon, presence: true
  enum :transaction_type, { expense: 'expense', income: 'income' }

  # Validate delete_flag to be either true or false
  attribute :delete_flag

end
