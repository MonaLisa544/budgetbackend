FactoryBot.define do
  factory :transaction do
    transaction_name { "Sample Transaction" }
    transaction_amount { 100.00 }
    transaction_date { Date.today }
    description { "Sample description" }
    frequency { false }
    delete_flag { false }
    association :user
    association :category
  end
end
