require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { 
    described_class.new(
      firstName: "John", 
      lastName: "Doe", 
      email: "john.doe@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  }

  # Associations
  it { should have_many(:transactions) }
  it { should have_many(:categories) }

  # Validations
  it { should validate_presence_of(:firstName) }
  it { should validate_presence_of(:lastName) }
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).case_insensitive }
  it { should validate_presence_of(:password).on(:create) }
  it { should validate_confirmation_of(:password) }
  it { should validate_length_of(:password).is_at_least(8).on(:create) }
  it { should validate_presence_of(:password_confirmation).on(:create) }

  # Active Storage
  it 'has one attached profile_photo' do
    expect(user.profile_photo).to be_an_instance_of(ActiveStorage::Attached::One)
  end

  # Devise modules
  it 'includes devise modules' do
    expect(user.devise_modules).to include(:database_authenticatable, :jwt_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :omniauthable)
  end

  # Custom methods
  describe '#password_required?' do
    context 'when skip_password_validation is true' do
      it 'returns false' do
        user.skip_password_validation = true
        expect(user.send(:password_required?)).to be false
      end
    end

    context 'when new record' do
      it 'returns true' do
        user.skip_password_validation = false
        expect(user.send(:password_required?)).to be true
      end
    end

    context 'when password is present' do
      it 'returns true' do
        user.skip_password_validation = false
        user.password = 'newpassword123'
        expect(user.send(:password_required?)).to be true
      end
    end

    context 'when password_confirmation is present' do
      it 'returns true' do
        user.skip_password_validation = false
        user.password_confirmation = 'newpassword123'
        expect(user.send(:password_required?)).to be true
      end
    end

    context 'when neither password nor password_confirmation is present' do
      it 'returns false' do
        user.skip_password_validation = false
        user.password = nil
        user.password_confirmation = nil
        puts "DEBUG: user.password = #{user.password.inspect}, user.password_confirmation = #{user.password_confirmation.inspect}, user.new_record? = #{user.new_record?}"
        expect(user.send(:password_required?)).to be false
      end
    end
  end
end
