class Transaction < ApplicationRecord
    before_create :set_default_transaction_date
  
    belongs_to :user
    belongs_to :category
    belongs_to :wallet
  
    # Polymorphic холбоо (Saving, Credit гэх мэт зүйлсийн төлбөрийг холбох)
    belongs_to :source, polymorphic: true, optional: true
  
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

    after_create  :update_loan_paid_amount
    after_update  :update_loan_paid_amount
    after_destroy :update_loan_paid_amount

    
  
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
  
      # Гүйлгээний огноонд таарах тухайн wallet ба category-тай төсөв хайна
      budget = Budget.where(
        category_id: category_id,
        wallet_id: wallet_id
      ).where("start_date <= ? AND due_date >= ?", transaction_date, transaction_date).first
  
      return unless budget
  
      total_used = Transaction.where(
        category_id: category_id,
        wallet_id: wallet_id,
        delete_flag: false
      ).where("transaction_date BETWEEN ? AND ?", budget.start_date, budget.due_date)
       .sum(:transaction_amount)
  
      budget.update(used_amount: total_used)
    end

    def update_loan_paid_amount
      return unless source_type == "Loan" && source_id.present?
    
      loan = source
      return unless loan.is_a?(Loan)
    
      total_paid = Transaction.where(
        source_type: "Loan",
        source_id: loan.id,
        delete_flag: false
      ).sum(:transaction_amount)
    
      loan.update_column(:paid_amount, total_paid)
    end

  end
  