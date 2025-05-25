class MonthlyBudget < ApplicationRecord
  belongs_to :budget

  validates :month, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :used_amount, numericality: { greater_than_or_equal_to: 0 }

  attribute :delete_flag, :boolean, default: false

  # Үлдэгдэл тооцоолол
  def remaining_amount
    amount.to_f - used_amount.to_f
  end

  # Мөнгөн дүнгээр харьцуулсан статус
  def spending_status
    if used_amount.to_f > amount.to_f
      'overdue'
    elsif used_amount.to_f == amount.to_f
      'completed'
    else
      'active'
    end
  end

  # Цаг хугацааны байдлаар статус
  def timeline_status
    today = Date.today
    year, month = self.month.split('-').map(&:to_i)
    budget_month_date = Date.new(year, month, 1)

    if budget_month_date < today.beginning_of_month
      'past'
    elsif budget_month_date == today.beginning_of_month
      'active'
    else
      'upcoming'
    end
  end
end
