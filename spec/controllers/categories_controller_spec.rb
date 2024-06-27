require 'rails_helper'

RSpec.describe Api::V1::CategoriesController, type: :controller do
  let(:user) { create(:user) } 

  before do
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    context 'when categories exist' do
      let!(:category1) { create(:category, user: user, delete_flag: false, transaction_type: 'expense') }
      let!(:category2) { create(:category, user: user, delete_flag: false, transaction_type: 'income') }

      it 'returns categories filtered by type' do
        get :index, params: { type: 'expense' }
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['data'].count).to eq(1)
        expect(JSON.parse(response.body)['data'].first['attributes']['transaction_type']).to eq('expense')
      end

      it 'returns all categories when no type parameter is given' do
        get :index
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body)['data'].length).to eq(2)
      end
    end

    context 'when no categories exist' do
      it 'returns not found error' do
        get :index
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['errors']['name']).to include('Category not found')
      end
    end
  end

  describe 'GET #show' do
    let(:category) { create(:category, user: user, delete_flag: false) }

    it 'returns the category' do
      get :show, params: { id: category.id }
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)['data']['id']).to eq(category.id.to_s)
    end

    it 'returns not found error when category does not exist' do
      get :show, params: { id: 'invalid_id' }
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['errors']['name']).to include('Category not found')
    end
  end

  describe 'POST #create' do
    let(:valid_params) { { category: attributes_for(:category, user_id: user.id) } }
    let(:invalid_params) { { category: attributes_for(:category, name: nil, user_id: user.id) } }

    context 'with valid params' do
      it 'creates a new category' do
        expect {
          post :create, params: valid_params
        }.to change(Category, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable entity error' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to include("Name can't be blank")
      end
    end
  end

  describe 'PATCH #update' do
    let(:category) { create(:category, user: user, delete_flag: false) }
    let(:valid_params) { { id: category.id, category: { name: 'Updated Category Name' } } }
    let(:invalid_params) { { id: category.id, category: { name: nil } } }

    context 'with valid params' do
      it 'updates the category' do
        patch :update, params: valid_params
        expect(response).to have_http_status(:success)
        expect(category.reload.name).to eq('Updated Category Name')
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable entity error' do
        patch :update, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']['name']).to include("can't be blank")
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:category) { create(:category, user: user, delete_flag: false) }

    it 'soft-deletes the category' do
      delete :destroy, params: { id: category.id }
      expect(response).to have_http_status(:success)
      expect(category.reload.delete_flag).to be_truthy
    end
  end
end
