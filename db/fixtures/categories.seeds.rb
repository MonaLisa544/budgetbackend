
require 'csv'

csv_file = Rails.root.join("db/fixtures/data/category.csv")


CSV.foreach(csv_file, headers: true) do |row|
  user = User.find_by(id: row['user_id'])
  if user.nil?
    puts "User not found"
    next
  end

  Category.seed do |s|
    s.name = row['name']
    s.icon = row['icon']
    s.user = user
  end
end
