class Transaction < ApplicationRecord
    before_create :set_default_transaction_date

    belongs_to :user
    belongs_to :category # dependent: :destroy

    validates :transaction_name, presence: true
    validates :transaction_amount, presence: true, numericality: { greater_than: 0 }
    attribute :transaction_date
    attribute :description
    attribute :frequency
    attribute :delete_flag

    private
    def set_default_transaction_date
        self.transaction_date ||= Date.today
    end


end
