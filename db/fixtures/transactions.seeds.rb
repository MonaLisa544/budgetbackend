require 'csv'

csv_file = Rails.root.join("db/fixtures/data/transaction.csv")

CSV.foreach(csv_file, headers: true) do |row|
  category = Category.find_by(name: row['category_name'])

  if category.nil?
    puts "Category not found"
    next
  end

  Transaction.seed do |s|
    s.transaction_amount = row['transaction_amount']
    s.transaction_type = row['transaction_type']
    s.description = row['description']
    s.category = category
  end
end
