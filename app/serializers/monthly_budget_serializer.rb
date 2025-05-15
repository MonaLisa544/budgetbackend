class MonthlyBudgetSerializer
    include FastJsonapi::ObjectSerializer
  
    attributes :id, :month, :amount, :used_amount
  
    attribute :remaining_amount do |object|
      object.remaining_amount
    end
  
    attribute :spending_status do |object|
      object.spending_status
    end
  
    attribute :timeline_status do |object|
      object.timeline_status
    end
  end
  