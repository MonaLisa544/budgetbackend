class Goal < ApplicationRecord
  belongs_to :wallet
  has_many :transactions
  has_many :goal_monthly_statuses, dependent: :destroy

  enum goal_type: { saving: 'saving', loan: 'loan' }
  enum status: { active: 'active', completed: 'completed' }

  validates :goal_name, presence: true, length: { maximum: 50 }
  validates :target_amount, presence: true, numericality: { greater_than: 0 }
  validates :goal_type, presence: true, inclusion: { in: goal_types.keys }
  validates :start_date, presence: true
  validates :expected_date, presence: true
  validates :monthly_due_day, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 31 }
  validates :description, length: { maximum: 255 }, allow_blank: true
  validates :status, inclusion: { in: statuses.keys }

  attribute :delete_flag, :boolean, default: false

  # Хэдэн сар үлдсэн бэ?
  def months_left
    return 0 unless start_date && expected_date
    ((expected_date.year * 12 + expected_date.month) - (start_date.year * 12 + start_date.month)).clamp(0, Float::INFINITY)
  end

  # Төлөх ёстой сар бүрийн дүн
  def calculated_monthly_payment
    return 0 if target_amount.blank? || months_left == 0
    (target_amount / months_left.to_f).round(2)
  end
end
