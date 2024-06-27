require 'rails_helper'

RSpec.describe PasswordMailer, type: :mailer do
  describe '#reset' do
    let(:user) { create(:user, email: 'test@example.com') }  # Adjust attributes as per your User model

    it 'sends password reset instructions to user' do
      mail = PasswordMailer.with(user: user).reset

      # Test the content of the sent email
      expect(mail.subject).to eq('Password Reset Instructions')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['noreply@example.com'])  # Update with your expected sender email
      expect(mail.body.encoded).to match("Hello #{user.firstName}")

      # Test the content of the reset link
      expect(mail.body.encoded).to include(CGI.escape(user.signed_id(purpose: 'password_reset', expires_in: 15.minutes)))
    end
  end
end
