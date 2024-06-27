# app/models/category.rb

class Category < ApplicationRecord
  has_many :transactions
  belongs_to :user
  validates :name, presence: true
  attribute :icon
  validates :name, uniqueness: { scope: :transaction_type, conditions: -> { where(delete_flag: false) }, scope: :user_id } 

  enum :transaction_type, { expense: 'expense', income: 'income' }
  attribute :delete_flag
end
git status 
