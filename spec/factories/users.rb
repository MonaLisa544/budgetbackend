require 'faker'

FactoryBot.define do
  factory :user do
    firstName { "John" }
    lastName { "Doe" }
    email { Faker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }

    after(:build) do |user|
      user.profile_photo.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'default_user_profile.png')), filename: 'profile_photo.png', content_type: 'image/png')
    end
  end
end
