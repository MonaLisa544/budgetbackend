class Budget < ApplicationRecord
  belongs_to :wallet
  belongs_to :category

  # Associations
  has_many :transactions, dependent: :destroy

  # Attributes
  attribute :delete_flag, :boolean, default: false
  attribute :used_amount, :decimal, default: 0

  # Валидациуд
  validates :budget_name, presence: true, length: { maximum: 50 }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :used_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :start_date, :due_date, presence: true
  validates :description, length: { maximum: 255 }, allow_blank: true

  enum status: { active: "active", completed: "completed", overdue: "overdue" }
  validates :status, inclusion: { in: statuses.keys }

  validate :pay_due_date_must_be_before_due_date, if: -> { pay_due_date.present? }

  # Scope
  scope :active, -> { where(status: "active") }

  # Runtime үлдэгдэл
  def remaining_amount
    amount.to_f - used_amount.to_f
  end

  private

  def pay_due_date_must_be_before_due_date
    if pay_due_date > due_date
      errors.add(:pay_due_date, "must be on or before due date")
    end
  end
end
