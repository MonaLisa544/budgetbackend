FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category#{n}" }
    icon { "iconTest"}
    transaction_type { "expense" }
    delete_flag { false }
    association :user
  end
end
