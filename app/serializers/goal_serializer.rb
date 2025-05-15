class GoalSerializer
    include FastJsonapi::ObjectSerializer
  
    attributes :id,
               :goal_name,
               :goal_type,
               :status,
               :target_amount,
               :paid_amount,
               :remaining_amount,
               :start_date,
               :expected_date,
               :monthly_due_day,
               :description
  
    attribute :months_left do |goal|
      if goal.start_date && goal.expected_date
        ((goal.expected_date.year * 12 + goal.expected_date.month) -
         (goal.start_date.year * 12 + goal.start_date.month)).clamp(0, Float::INFINITY)
      else
        0
      end
    end
    attribute :wallet_type do |budget|
      case budget.wallet.owner_type
      when "User"
        "private"
      when "Family"
        "family"
      else
        "unknown"
      end
    end
  
    belongs_to :wallet

    
  end
  