class User < ApplicationRecord
  devise :database_authenticatable,
         :jwt_authenticatable,
         :registerable,
         :recoverable, :rememberable, :validatable, 
         :omniauthable, omniauth_providers: [:google_oauth2],
         jwt_revocation_strategy: JwtDenylist

  has_many :transactions
  has_many :categories
  validates :lastName, presence: true
  validates :firstName, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, confirmation: true, length: { minimum: 8 }, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  has_one_attached :profile_photo

  attr_accessor :skip_password_validation

  def self.from_google(u)
    create_with(uid: u[:uid], provider: 'google',
                password: Devise.friendly_token[0, 20]).find_or_create_by!(email: u[:email])
end
  private
    def password_required?
      return false if skip_password_validation
      new_record? || password.present? || password_confirmation.present?
    end
end