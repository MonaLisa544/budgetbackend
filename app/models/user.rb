class User < ApplicationRecord
  devise :database_authenticatable,
         :jwt_authenticatable,
         :registerable,
         :omniauthable, omniauth_providers: %i[facebook],
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

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.firstName = auth.info.first_name
      user.lastName = auth.info.last_name
    end
  end

  private
    def password_required?
      return false if skip_password_validation
      new_record? || password.present? || password_confirmation.present?
    end
end
