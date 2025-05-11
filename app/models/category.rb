class Category < ApplicationRecord
  has_many :transactions
  belongs_to :user

  validates :category_name, presence: true
  validates :transaction_type, presence: true
  validates :category_name, uniqueness: {
    scope: [:transaction_type, :user_id],
    conditions: -> { where(delete_flag: false) }
  }

  enum transaction_type: { expense: 'expense', income: 'income' }

  # Icon болон icon color талбаруудыг хадгалах
  attribute :icon, :string
  attribute :icon_color, :string
  attribute :delete_flag, :boolean, default: false
end
