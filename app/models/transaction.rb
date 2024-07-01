class Transaction < ApplicationRecord
    before_create :set_default_transaction_date

    belongs_to :user
    belongs_to :category

    validates :transaction_name, presence: true, length: { maximum: 20}
    validates :transaction_amount, presence: true, numericality: { greater_than: 0}, length: {maximum: 10}
    attribute :transaction_date
    validates :description, length: { maximum: 50}
    attribute :frequency
    attribute :delete_flag

    scope :active_transaction, ->(user_id) {
        where(user_id: user_id, delete_flag: false)
    }

    scope :filter_by_date, ->(start_date, end_date, user_id) {
        active_transaction(user_id).where(transaction_date: start_date..end_date)
    }

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
                transaction_name: transaction_name,
                transaction_amount: transaction_amount,
                transaction_date: date,
                frequency: frequency,
                category_id: category_id,
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
    def set_default_transaction_date
        self.transaction_date ||= Date.today
    end
end
