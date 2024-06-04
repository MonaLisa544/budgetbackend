class Transaction < ApplicationRecord 

    # belongs_to :user
    belongs_to :category, dependent: :destroy

    validates :transaction_amount, presence: true
    validates :transation_date, presence: true
    validates :transaction_type, presence: true
    validates :description, presence: true
    validates :frequency, presence: true
    validates :delete_flag, presence: true


    
end                             