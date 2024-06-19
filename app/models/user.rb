class User < ApplicationRecord
  devise :database_authenticatable,
         :jwt_authenticatable,
         :registerable,
         :recoverable, :rememberable, :validatable, 
         :omniauthable, omniauth_providers: [:google_oauth2, :facebook],
         jwt_revocation_strategy: JwtDenylist

  include RoleConstants

  has_many :transactions
  has_many :categories
  validates :lastName, presence: true
  validates :firstName, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, confirmation: true, length: { minimum: 8 }, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  has_one_attached :profile_photo

  attr_accessor :skip_password_validation

  def self.from_omniauth(access_token)
    user = User.where(email: access_token.info.email).first
    unless user = User.create(
      email: access_token.info.email,
      password: Devise.friendly_token[0,20]
      )
    end 
    user.firstName = access_token.info.name
    user.image = access_token.info.image
    user.uid = access_token.uid
    user.provider = access_token.provider
    user.save

    user
  end

  private
    def password_required?
      return false if skip_password_validation
      new_record? || password.present? || password_confirmation.present?
    end
end

# def self.from_google(u)
#   create_with(uid: u[:uid], provider: 'google',
#               password: Devise.friendly_token[0, 20]).find_or_create_by!(email: u[:email])
# end

# def self.from_omniauth(auth)
#   name_split = auth.info.name.split(" ")
#   user = User.where(email: auth.info.email).first
#   user ||= User.create!(provider: auth.provider, uid: auth.uid, lastName: name_split[0], firstName: name_split[1], email: auth.info.email, password: Devise.friendly_token[0, 20])
#     user
# end
