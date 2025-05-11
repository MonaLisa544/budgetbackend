class User < ApplicationRecord
  # Devise authentication тохиргоо
  devise :database_authenticatable,
         :jwt_authenticatable,
         :registerable,
         :recoverable, :rememberable, :validatable,
         jwt_revocation_strategy: JwtDenylist

  # Холбоосууд
  belongs_to :family, optional: true
  has_one :wallet, as: :owner, dependent: :destroy
  
  has_many :transactions
  has_many :categories
  has_many :notifications

  has_one_attached :profile_photo

  # Role enum
  enum role: { member: 0, admin: 1, child: 2 }

  # Validation-ууд
  validates :lastName, presence: true
  validates :firstName, presence: true
  validates :email, uniqueness: true
  validates :password, presence: true, confirmation: true, length: { minimum: 8 }, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?
  validates :role, inclusion: { in: roles.keys }

  # Password validation control
  attr_accessor :skip_password_validation

  # Callbacks
  after_initialize :set_default_role, if: :new_record?
  after_create :create_wallet_for_user

  private

  def password_required?
    return false if skip_password_validation
    new_record? || password.present? || password_confirmation.present?
  end

  def set_default_role
    self.role ||= :member
  end

  def create_wallet_for_user
    create_wallet(balance: 0)
  end
end
