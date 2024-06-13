# app/models/category.rb

class Category < ApplicationRecord
  has_many :transactions
  belongs_to :user
    # Validate presence of name attribute
  validates :name, presence: true
  validates :icon, presence: true
  validates :name, uniqueness: { scope: :transaction_type, conditions: -> { where(delete_flag: false) } }

  enum :transaction_type, { expense: 'expense', income: 'income' }
  attribute :delete_flag
end
