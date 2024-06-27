require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  let(:user) {create (:user)}

  describe 'POST #create' do

    context 'with valid credentials' do
      it 'successfully authorizes user' do
        post :create, params: {user: {email: user.email, password: user.password}}
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['token']).to be_present
      end
    end

    context 'with invalid credentials' do
      it 'returns not registered error if user not exists' do
        post :create, params: {user: {email: 'tuug@gmail.com', password: '1234tuug'}}
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq("Not registered. Please sign up!")
      end

      it 'returns incorrect password if user exists' do
        post :create, params: {user: {email: user.email, password: 'wrongpass'}}
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq("Password incorrect. Please try again!")
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user is logged in' do
      before { sign_in(user) }
      it 'returns a success response' do
        delete :destroy
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)['message']).to eq("Logged out.")
      end
    end

    context 'when user is not logged in' do
      it 'returns an unauthorized response' do
        delete :destroy
        expect(response).to have_http_status(401)
        expect(JSON.parse(response.body)['message']).to eq("Logged out failure.")
      end
    end
  end
end
