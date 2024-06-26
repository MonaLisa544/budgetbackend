# spec/models/category_spec.rb

require 'rails_helper'

RSpec.describe Category, type: :model do
  subject(:category) { 
    described_class.new(
      name: "Groceries",
      icon: "groceries_icon.png",
      transaction_type: :expense,
      user: user
    )
  }

  let(:user) { User.create(firstName: "John", lastName: "Doe", email: "john.doe@example.com", password: "password123", password_confirmation: "password123") }

  # Associations
  it { should have_many(:transactions) }
  it { should belong_to(:user) }

  # Validations
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:icon) }
  
  it 'validates uniqueness of name scoped to transaction_type where delete_flag is false' do
    existing_category = described_class.create(
      name: "Groceries",
      icon: "groceries_icon.png",
      transaction_type: :expense,
      user: user,
      delete_flag: false
    )
    category.transaction_type = existing_category.transaction_type
    expect(category).to validate_uniqueness_of(:name).scoped_to(:transaction_type).case_insensitive
  end

  # Enums
  it 'defines transaction_type as an enum with correct values' do
    expect(described_class.transaction_types.keys).to contain_exactly('expense', 'income')
  end

  # Custom attributes
  it 'has a delete_flag attribute' do
    expect(category.attributes).to include('delete_flag')
  end
end
