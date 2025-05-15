FactoryBot.define do
  factory :monthly_budget do
    budget { nil }
    month { "MyString" }
    amount { "9.99" }
    used_amount { "9.99" }
  end
end
