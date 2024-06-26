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

    private
    def set_default_transaction_date
        self.transaction_date ||= Date.today
    end
end
