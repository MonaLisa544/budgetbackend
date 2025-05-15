class BudgetSerializer
  include FastJsonapi::ObjectSerializer

  attributes :budget_name,
             :amount,
             :used_amount,
             :start_date,
             :due_date,
             :pay_due_date,
             :status,
             :description

  belongs_to :wallet
  

  # Status харуулах (e.g., "Active", "Completed")
  attribute :status_label do |budget|
    budget.status.capitalize
  end

  # Wallet-ийн эзэмшигчийг гаргах (e.g., owner_type: "User", owner_id: 2)
  attribute :owner_type do |budget|
    budget.wallet.owner_type
  end

  attribute :owner_id do |budget|
    budget.wallet.owner_id
  end

  attribute :category_name do |budget|
    budget.category&.category_name
  end

  attribute :category_icon do |budget|
    budget.category&.icon
  end

  attribute :category_icon_color do |budget|
    budget.category&.icon_color
  end
end
