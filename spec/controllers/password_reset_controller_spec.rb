require 'rails_helper'

RSpec.describe PasswordResetsController, type: :controller do
  describe 'POST #create' do
    context 'when valid email is provided' do
      let(:user) { create(:user) }  # Assuming you have FactoryBot or a similar factory set up

      it 'sends password reset instructions' do
        post :create, params: { email: user.email }

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Password reset instructions sent to your email')
        expect(json_response['reset_password_token']).to be_present
      end
    end

    context 'when invalid email is provided' do
      it 'returns not found error' do
        post :create, params: { email: 'nonexistent@example.com' }

        expect(response).to have_http_status(:not_found)
        expect(json_response['error']).to eq('Email not found')
      end
    end
  end

  describe 'GET #edit' do
    let(:user) { create(:user) }
    let(:token) { user.signed_id(purpose: 'password_reset', expires_in: 15.minutes) }

    context 'with valid token' do
      it 'renders edit template' do
        get :edit, params: { token: token }

        expect(response).to have_http_status(:success)
        #expect(assigns(:user)).to eq(user)
      end
    end

    context 'with invalid/expired token' do
      let(:invalid_token) { 'invalid_token' }

      it 'returns unprocessable entity error' do
        get :edit, params: { token: invalid_token }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Your token has expired or is invalid. Please request a new password reset.')
      end
    end
  end

  describe 'PATCH #update' do
    let(:user) { create(:user) }
    let(:token) { user.signed_id(purpose: 'password_reset', expires_in: 15.minutes) }
    let(:new_password) { 'new_password' }

    context 'with valid token and valid params' do
      it 'updates user password' do
        patch :update, params: { token: token, user: { password: new_password, password_confirmation: new_password } }

        expect(response).to have_http_status(:ok)
        expect(json_response['message']).to eq('Your password was reset successfully. Please sign in.')
      end
    end

    context 'with valid token and invalid params' do
      it 'returns unprocessable entity error' do
        patch :update, params: { token: token, user: { password: new_password, password_confirmation: 'wrong_confirmation' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include("Password confirmation doesn't match Password")
      end
    end

    context 'with invalid/expired token' do
      let(:invalid_token) { 'invalid_token' }

      it 'returns unprocessable entity error' do
        patch :update, params: { token: invalid_token, user: { password: new_password, password_confirmation: new_password } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']).to eq('Your token has expired or is invalid. Please request a new password reset.')
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
