class GoalMonthlyStatus < ApplicationRecord
  belongs_to :goal

  validates :month, presence: true
  validates :status, inclusion: { in: ["success", "failed", "pending"] }
end
