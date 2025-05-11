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
  belongs_to :category

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
end
