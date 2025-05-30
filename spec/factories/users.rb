require 'faker'

FactoryBot.define do
  factory :user do
    firstName { "Tuugu" }
    lastName { "Chimgee" }
    email { Faker::Internet.email }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
