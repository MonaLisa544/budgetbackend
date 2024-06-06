class Transaction < ApplicationRecord 

    belongs_to :user
    belongs_to :category # dependent: :destroy

    validates :transaction_name, presense: true
    validates :transaction_amount, presence: true
    attribute :transaction_date
    attribute :transaction_type
    attribute :description
    attribute :frequency
    attribute :delete_flag

    
end                             