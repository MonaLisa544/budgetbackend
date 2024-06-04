
require 'csv'

csv_file = Rails.root.join("db/fixtures/data/category.csv")

CSV.foreach(csv_file, headers: true) do |row|
  Category.seed_once(:id) do |s|
    s.name = row['name']
  end
end
