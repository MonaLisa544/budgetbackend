class Transaction < ApplicationRecord
    before_create :set_default_transaction_date
  
    belongs_to :user
    belongs_to :category
    belongs_to :wallet

    belongs_to :goal, optional: true 
    
  
    validates :transaction_name, presence: true, length: { maximum: 20 }
    validates :transaction_amount, presence: true, numericality: { greater_than: 0 }, length: { maximum: 10 }
    validates :description, length: { maximum: 50 }
  
    attribute :transaction_date
    attribute :frequency
    attribute :delete_flag
  
    # Scope-ууд
    scope :active_transaction, ->(user_id) {
      where(user_id: user_id, delete_flag: false)
    }
  
    scope :filter_by_date, ->(start_date, end_date, user_id) {
      active_transaction(user_id).where(transaction_date: start_date..end_date)
    }


    after_create  :update_related_budget_used_amount
    after_update  :update_related_budget_used_amount
    after_destroy :update_related_budget_used_amount
    

    after_create  :update_goal_paid_amount
after_update  :update_goal_paid_amount
after_destroy :update_goal_paid_amount

after_save :update_goal_progress, if: :goal_id?


    
  
    # Methods
    def schedule
      schedule = IceCube::Schedule.new(self.transaction_date)
      schedule.add_recurrence_rule IceCube::Rule.monthly.day_of_month(self.transaction_date.day)
      schedule
    end
  
    def create_recurring
      end_date = transaction_date + 1.year
      schedule.occurrences(end_date).map do |date|
        self.class.create!(
          user_id: user_id,
          wallet_id: wallet_id,
          transaction_name: transaction_name,
          transaction_amount: transaction_amount,
          transaction_date: date,
          frequency: frequency,
          category_id: category_id
        )
      end
    end
  
    def delete_associated_recurring_transactions
      self.class.where(
        user_id: user_id,
        transaction_name: transaction_name,
        transaction_amount: transaction_amount,
        category_id: category_id,
        frequency: true
      ).where("DAY(transaction_date) = ? AND transaction_date > ?", transaction_date.day, transaction_date)
       .update_all(delete_flag: true)
    end
  
    private

    def update_wallet_balance
      if income?
        wallet.increase(amount)
      elsif expense?
        wallet.decrease(amount)
      end
    end
  
    def set_default_transaction_date
      self.transaction_date ||= Date.today
    end

    def update_related_budget_used_amount
      return unless category_id && wallet_id && transaction_date
    
      # 1. Category-аас budget_id-г олно
      category = Category.find_by(id: category_id)
      return unless category && category.budget_id
    
      # 2. Гүйлгээний огнооны сар (2025-05 гэх мэт) олно
      budget_month = transaction_date.strftime("%Y-%m")
    
      # 3. MonthlyBudget-ээ олно
      monthly_budget = MonthlyBudget.find_by(budget_id: category.budget_id, month: budget_month)
      return unless monthly_budget
    
      # 4. Тухайн сар, budget_id-д харгалзах бүх гүйлгээний нийлбэр
      total_used = Transaction.where(
        category_id: category_id,
        wallet_id: wallet_id,
        delete_flag: false
      ).where("DATE_FORMAT(transaction_date, '%Y-%m') = ?", budget_month)
       .sum(:transaction_amount)
    
      monthly_budget.update(used_amount: total_used)
    end



def update_goal_paid_amount
  return unless goal_id.present?

  goal = Goal.find_by(id: goal_id)
  return unless goal

  total_paid = Transaction.where(goal_id: goal.id, delete_flag: false).sum(:transaction_amount)

  goal.update_columns(
    paid_amount: total_paid,
    remaining_amount: [goal.target_amount - total_paid, 0].max
  )
end


def update_goal_progress
  year = transaction_date.year
  month = transaction_date.month

  GoalProgressService.check_monthly_progress(goal, year, month)
end



  end
  