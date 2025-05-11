class Wallet < ApplicationRecord
  has_many :transactions
  has_many :savings
  has_many :credits

  belongs_to :owner, polymorphic: true

  validates :balance, presence: true
  attribute :delete_flag

  def increase(amount)
    update(balance: balance + amount)
  end

  def decrease(amount)
    update(balance: balance - amount)
  end

  
end
