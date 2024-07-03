require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:category) }
  end

  describe 'validations' do
    it { should validate_presence_of(:transaction_name) }
    it { should validate_presence_of(:transaction_amount) }
    it { should validate_numericality_of(:transaction_amount).is_greater_than(0) }
  end

  describe 'callbacks' do
    describe '#set_default_transaction_date' do
      context 'when transaction_date is not set' do
        it 'sets transaction_date to today' do
          transaction = FactoryBot.create(:transaction, transaction_date: nil)
          expect(transaction.transaction_date).to eq(Date.today)
        end
      end

      context 'when transaction_date is already set' do
        it 'does not change transaction_date' do
          date = 1.month.ago.to_date
          transaction = FactoryBot.create(:transaction, transaction_date: date)
          expect(transaction.transaction_date).to eq(date)
        end
      end
    end
  end
  describe '#create_recurring' do
    it 'creates recurring transactions for the next year' do
      user = FactoryBot.create(:user)
      category = FactoryBot.create(:category)
      transaction = FactoryBot.create(
        :transaction,
        user: user,
        category: category,
        transaction_name: 'Test Transaction',
        transaction_amount: 100,
        transaction_date: Date.today,
        frequency: 'monthly'
      )

      expect {
        transaction.create_recurring
      }.to change { Transaction.count }.by(12)

      recurring_transactions = Transaction.where(user: user, transaction_name: 'Test Transaction').order(:transaction_date)
      recurring_transactions.each_with_index do |recurring_transaction, index|
        expect(recurring_transaction.transaction_date).to eq(Date.today + index.months)
        expect(recurring_transaction.transaction_amount).to eq(100)
        expect(recurring_transaction.category).to eq(category)
        expect(recurring_transaction.frequency).to eq(true)
      end
    end
  end
end
