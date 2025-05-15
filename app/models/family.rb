class Family < ApplicationRecord
    has_secure_password

    has_many :users
    has_many :budgets
    has_one :wallet, as: :owner, dependent: :destroy

    validates :family_name, presence: true, uniqueness: true
    validates :password, presence: true, length: { minimum: 4 }, on: :create
    attribute :delete_flag, :boolean, default: false


    after_create :create_wallet_for_family


    private 
    def create_wallet_for_family
      create_wallet(balance: 0)
    end


  end