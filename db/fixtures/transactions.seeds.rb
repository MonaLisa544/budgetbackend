require 'csv'

csv_file = Rails.root.join("db/fixtures/data/transaction.csv")

CSV.foreach(csv_file, headers: true) do |row|
  user = User.find_by(id: row['user_id'])
  category = Category.find_by(name: row['category_name'])


  if user.nil?
    puts "User not found"
    next
  end
  if category.nil?
    puts "Category not found"
    next
  end

  Transaction.seed do |s|
    s.transaction_amount = row['transaction_amount']
    s.description = row['description']
    s.user = user
    s.category = category
  end
end
