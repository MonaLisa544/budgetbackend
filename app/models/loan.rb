class Loan < ApplicationRecord
  belongs_to :wallet
  has_many :transactions, as: :source , dependent: :destroy

  enum status: { active: "active", completed: "completed", overdue: "overdue" }

  validates :loan_name, presence: true, length: { maximum: 50 }
  validates :loan_type, length: { maximum: 50 }, allow_blank: true

  validates :original_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :interest_rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  validates :monthly_payment_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :monthly_due_day, numericality: { greater_than: 0, less_than_or_equal_to: 31 }, allow_nil: true

  validates :start_date, presence: true
  validates :due_date, presence: true

  validates :status, inclusion: { in: statuses.keys }
  validates :description, length: { maximum: 255 }, allow_blank: true

  attribute :total_amount_due, :integer, default: 0
  attribute :paid_amount, :integer, default: 0


  # 🧮 Нийт төлөх дүн (хүүтэй нийлээд)
  def total_amount_due
    return original_amount if interest_rate.blank?
    original_amount + (original_amount * interest_rate / 100)
  end

  # 🧮 Үлдэгдэл
  def remaining_amount
    total_amount_due - paid_amount
  end
end
