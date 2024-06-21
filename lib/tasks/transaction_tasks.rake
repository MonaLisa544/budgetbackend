namespace :transactions do
  desc "Insert recurring transactions into the database"
  task insert_recurring: :environment do
    Transaction.where(frequency: true, delete_flag: false).find_each do |transaction|
      Transaction.create!(
        user_id: transaction.user_id,
        transaction_name: transaction.transaction_name,
        transaction_amount: transaction.transaction_amount,
        transaction_date: Date.today,
        description: transaction.description,
        frequency: transaction.frequency,
        category_id: transaction.category_id,
        delete_flag: false
      )
    end
  end
end
