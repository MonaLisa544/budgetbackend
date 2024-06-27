require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }
  before { sign_in(user) }

  describe 'GET #show' do
    it 'returns the user profile' do
      get :show
      expect(response).to have_http_status(200)
      json_response = JSON.parse(response.body)
      expect(json_response['firstName']).to eq(user.firstName)
      expect(json_response['lastName']).to eq(user.lastName)
      expect(json_response['email']).to eq(user.email)
    end

    it 'attaches a default profile photo if not exists' do
      user.profile_photo.purge  # deletes file from the storage service
      get :show
      user.reload
      expect(user.profile_photo.attached?).to be true
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:valid_params) do
        {
          user: {
            firstName: 'Tuguldurchimeg',
            lastName: 'Ren',
            email: 'tuugu@example.com'
          }
        }
      end

      it 'updates the user' do
        put :update, params: valid_params
        user.reload
        expect(user.firstName).to eq('Tuguldurchimeg')
        expect(user.lastName).to eq('Ren')
        expect(user.email).to eq('tuugu@example.com')
      end

      it 'returns a success message' do
        put :update, params: valid_params
        expect(response).to have_http_status(200)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Profile updated successfully')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          user: {
            firstName: '',
            lastName: '',
            email: 'invalidemail'
          }
        }
      end

      it 'does not update the user' do
        put :update, params: invalid_params
        user.reload
        expect(user.email).not_to eq('invalidemail')
      end

      it 'returns an error message' do
        put :update, params: invalid_params
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['errors']).to include("Firstname can't be blank",
                                                              "Lastname can't be blank",
                                                              "Email is invalid")
      end
    end

    context 'with a profile photo' do
      let(:base64_image) do
        img_file = './app/assets/images/default_user_profile.png'
        base64 = Base64.encode64(File.open(img_file, 'rb').read)
        base64
      end

      let(:photo_param) do
        {
          user: {
            profile_photo: base64_image
          }
        }
      end

      it 'attaches the profile photo' do
        put :update, params: photo_param
        expect(user.profile_photo.attached?).to be true
      end

      it 'returns an error for invalid base64' do
        put :update, params: { user: { profile_photo: 'invalid_base64' } }
        expect(response).to have_http_status(400)
        expect(JSON.parse(response.body)['errors']).to include('Failed to decode and attach image: uninitialized constant UsersController::MIME')
      end
    end
  end
end
