class Saving < ApplicationRecord
    belongs_to :wallet
    has_many :transactions, as: :source, dependent: :destroy
  
    enum status: { active: "active", completed: "completed", overdue: "overdue" }
  
    validates :saving_name, presence: true, length: { maximum: 50 }
    validates :target_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :start_date, presence: true
    validates :expected_date, presence: true
    validates :status, inclusion: { in: statuses.keys }
    validates :description, length: { maximum: 255 }, allow_blank: true
    # attribute :paid_amount, default: 0

    def remaining_amount
      target_amount - paid_amount
    end

  end