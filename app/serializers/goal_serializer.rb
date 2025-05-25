class GoalSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :goal_name, :goal_type, :status,
             :target_amount, :saved_amount,
             :start_date, :expected_date,
             :monthly_due_day, :monthly_due_amount,
             :description

  attribute :months_left do |goal|
    if goal.start_date && goal.expected_date
      ((goal.expected_date.year * 12 + goal.expected_date.month) -
       (goal.start_date.year * 12 + goal.start_date.month)).clamp(0, Float::INFINITY)
    else
      0
    end
  end

  attribute :wallet_type do |goal|
    case goal.wallet.owner_type
    when "User"
      "private"
    when "Family"
      "family"
    else
      "unknown"
    end
  end

  belongs_to :wallet

  # ⭐️ Энэ хэсгийг нэмнэ!
  attribute :monthly_statuses do |goal|
    goal.goal_monthly_statuses.order(:month).map do |gms|
      GoalMonthlyStatusSerializer.new(gms).serializable_hash[:data][:attributes]
    end
  end
end
