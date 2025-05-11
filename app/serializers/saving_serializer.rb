class SavingSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id,
             :saving_name,
             :target_amount,
             :paid_amount,
             :remaining_amount,
             :start_date,
             :expected_date,
             :status,
             :description,
             :wallet_id,
             :created_at,
             :updated_at

  # ✅ runtime дээр бодогдох үлдэгдэл
  attribute :remaining_amount do |saving|
    saving.target_amount - saving.paid_amount
  end
end
