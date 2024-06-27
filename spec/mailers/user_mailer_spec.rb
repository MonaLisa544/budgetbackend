require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe '#welcome_email' do
    let(:user) { create(:user, email: 'test@example.com', firstName: 'John', lastName: 'Doe') }  # Adjust attributes as per your User model

    it 'sends a welcome email to the user' do
      mail = UserMailer.welcome_email(user)

      # Test the content of the sent email
      expect(mail.subject).to eq('Welcome to Our Application!')
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(['noreply@example.com'])  # Update with your expected sender email
      expect(mail.body.encoded).to match("Hello #{user.firstName} #{user.lastName}")

      # Additional content verification if needed
      expect(mail.body.encoded).to include('Thank you for signing up!')
    end
  end
end
