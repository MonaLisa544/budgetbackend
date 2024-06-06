require 'csv'

csv_file = Rails.root.join("db/fixtures/data/users.csv")

CSV.foreach(csv_file, headers: true) do |row|

  User.seed do |s|
    s.lastName = row['lastName']
    s.firstName = row['firstName']
    s.email = row['email']
    s.password = row['password']
  end
end
