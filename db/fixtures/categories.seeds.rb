
require 'csv'

csv_file = Rails.root.join("db/fixtures/data(1).csv")

CSV.foreach(csv_file, headers: true) do |row|
  Category.seed do |s|
    s.name = row['name']
  end
end
