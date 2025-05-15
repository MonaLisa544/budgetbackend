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
               :description,
               :created_at,
               :updated_at
  
    attribute :progress_percentage do |goal|
      if goal.target_amount && goal.target_amount > 0
        ((goal.paid_amount.to_f / goal.target_amount) * 100).round(2)
      else
        0.0
      end
    end
  
    attribute :months_left do |goal|
      if goal.start_date && goal.expected_date
        ((goal.expected_date.year * 12 + goal.expected_date.month) -
         (goal.start_date.year * 12 + goal.start_date.month)).clamp(0, Float::INFINITY)
      else
        0
      end
    end
  
    belongs_to :wallet

    attribute :owner_type do |budget|
        budget.wallet.owner_type
      end 
  end
  