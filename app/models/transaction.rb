class Transaction < ApplicationRecord 

    validates :transaction_id, presence: true
end                             