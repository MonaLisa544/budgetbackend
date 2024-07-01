require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'welcome_email' do
    let(:user) { create(:user) }
    let(:mail) { described_class.with(user: user).welcome_email(user).deliver_now }

    it 'renders the subject' do
      expect(mail.subject).to eq('Welcome to Our Application!')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([user.email])
    end
  end
end