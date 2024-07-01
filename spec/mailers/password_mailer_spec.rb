require 'rails_helper'

RSpec.describe PasswordMailer, type: :mailer do
  describe 'reset' do
    let(:user) { create(:user) }  

    let(:mail) { described_class.with(user: user).reset.deliver_now }

    it 'renders the subject' do
      expect(mail.subject).to eq('Reset')
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([user.email])
    end
    
  end
end
