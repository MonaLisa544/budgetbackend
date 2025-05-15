class UserSerializer
  include FastJsonapi::ObjectSerializer

  attributes :firstName, :lastName, :email, :role

  attribute :profile_photo do |user|
    user.profile_photo.attached? ? Rails.application.routes.url_helpers.url_for(user.profile_photo) : nil
  end

  belongs_to :family
  belongs_to :wallet
end
