class LoanSerializer
  include FastJsonapi::ObjectSerializer

  attributes :loan_name,
             :loan_type,
             :original_amount,
             :interest_rate,
             :monthly_payment_amount,
             :monthly_due_day,
             :start_date,
             :due_date,
             :status,
             :description,
             :created_at,
             :updated_at

  belongs_to :wallet

  # 🧮 Тооцоологдсон утгууд
  attribute :total_amount_due do |loan|
    loan.total_amount_due
  end

  attribute :paid_amount do |loan|
    loan.paid_amount
  end

  attribute :remaining_amount do |loan|
    loan.remaining_amount
  end
end
