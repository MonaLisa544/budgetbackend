class Budget < ApplicationRecord
  belongs_to :wallet
  belongs_to :category

  # Associations
  has_many :monthly_budgets, dependent: :destroy # 🎯 холбоо нэмнэ

  # Attributes
  attribute :delete_flag, :boolean, default: false

  # Валидациуд
  validates :budget_name, presence: true, length: { maximum: 50 }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :description, length: { maximum: 255 }, allow_blank: true

  validates :pay_due_date, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 31 }, allow_nil: true

end
