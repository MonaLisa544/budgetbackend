class Transaction < ApplicationRecord 

    belongs_to :user
    belongs_to :category # dependent: :destroy

    validates :transaction_name, presence: true
    validates :transaction_amount, presence: true
    attribute :transaction_date
    enum :transaction_type, { Expences: 'ex', Income: 'in' }
    attribute :description
    attribute :frequency
    attribute :delete_flag

    
end                             