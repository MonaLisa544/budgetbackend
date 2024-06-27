require 'rails_helper'

RSpec.describe  Users::RegistrationsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    let(:valid_params) do {
      user: {
        firstName: 'Tuguldur',
        lastName: 'Bayrbat',
        email: 'btuguldur@gmail.com',
        password: 'tuugu123',
        password_confirmation: 'tuugu123'
      }
    }
    end
    let(:invalid_params) do {
      user: {
        firstName: '',
        lastName: '',
        email: 'myemail',
        password: 'password',
        password_confirmation: 'password'
      }
    }
    end
    context 'with valid params' do
      it 'successfully creates' do
        post :create, params: valid_params
        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to include("Welcome #{valid_params[:user][:firstName]} #{valid_params[:user][:lastName]}")
      end

      it 'creates default categories for user' do
        expect {
          post :create, params: valid_params
        }.to change(Category, :count).by(3)

        user = User.find_by(email: valid_params[:user][:email])
        categories = user.categories

        expect(categories.pluck(:name)).to match_array(['Цалин', 'Хоол хүнс', 'Хувцас'])
        expect(categories.pluck(:transaction_type)).to include('income', 'expense', 'expense')
      end

      it 'sends mail to user email' do
        expect {
          post :create, params: valid_params
        }.to change { ActionMailer::Base.deliveries.count }.by(1)

        user = User.find_by(email: valid_params[:user][:email])
        expect(ActionMailer::Base.deliveries.last.to).to eq([user.email])
      end
    end

    context 'with invalid params' do
      it 'doesnt create user with blank name' do
        post :create, params: invalid_params
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['message']).to include("Firstname can't be blank",
                                                                "Lastname can't be blank",
                                                                "Email is invalid")
      end
      it 'requires password to be minimum 8 length' do
        password_params = valid_params.merge(user: { password: '', password_confirmation: '' })
        post :create, params: password_params
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['message']).to include("Password is too short (minimum is 8 characters)",
                                                                "Password confirmation can't be blank")
      end
      it 'requires password & confirmation must match' do
        password_params = valid_params.merge(user: { password: 'pass1234', password_confirmation: 'pass4567' })
        post :create, params: password_params
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['message']).to include("Password confirmation doesn't match Password")
      end
    end
  end
end
