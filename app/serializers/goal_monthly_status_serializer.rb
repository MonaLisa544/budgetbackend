class GoalMonthlyStatusSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :month, :paid_amount, :status

  attribute :planned_amount do |gms|
    gms.goal.monthly_due_amount
  end

  belongs_to :goal
end
