class Transaction < ApplicationRecord 

    # belongs_to :user
    belongs_to :category, dependent: :destroy

    # validates :transaction_id, presence: true
    # validates :transaction_amount, presence: true
    # validates :transation_date, presence: true
    # validates :description
    # validates :frequency, presence: true
    # validates :delete_flag, presence: true


    
end                             