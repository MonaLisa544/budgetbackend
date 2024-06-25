require 'rails_helper'

RSpec.describe Api::V1::TransactionsController, type: :controller do
  let(:user) { create(:user) }
  before { sign_in(user) }

  describe 'GET #index' do
    context 'with transactions present' do
      let!(:transactions) { create_list(:transaction, 5, user: user) }

      it 'returns a success response' do
        get :index
        expect(response).to have_http_status(200)
      end

      it 'returns paginated transactions' do
        get :index, params: { per_page: 1, page: 1 }
        expect(response).to have_http_status(200)
        expect(json_response['data'].length).to eq(5)
      end
    end

    context 'without transactions' do
      it 'returns 404 if no transactions found' do
        get :index
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST #create' do
    let(:category) { create(:category, user: user) }
    let(:valid_attributes) { { transaction: attributes_for(:transaction, user_id: user.id, category_id: category.id) } }

    context 'with valid params' do
      it 'creates a new transaction' do
        expect {
          post :create, params: valid_attributes
        }.to change(Transaction, :count).by(1)
      end

      it 'renders a JSON response with the new transaction' do
        post :create, params: valid_attributes
        expect(response).to have_http_status(200)
        expect(response.content_type).to include('application/json')
      end
    end

    context 'with invalid params' do
      it 'returns a 422 error' do
        post :create, params: { transaction: { transaction_name: '', transaction_amount: -1 } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PUT #update' do
    let(:transaction) { create(:transaction, user: user) }
    let(:new_attributes) { { transaction: { transaction_name: 'Updated Name' } } }

    context 'with valid params' do
      it 'updates the requested transaction' do
        put :update, params: { id: transaction.to_param }.merge(new_attributes)
        transaction.reload
        expect(transaction.transaction_name).to eq('Updated Name')
      end

      it 'renders a JSON response with the transaction' do
        put :update, params: { id: transaction.to_param }.merge(new_attributes)
        expect(response).to have_http_status(200)
        expect(response.content_type).to include('application/json')
      end
    end

    context 'with empty transaction_name' do
      it 'returns a 422 error' do
        put :update, params: { id: transaction.to_param, transaction: { transaction_name: '' } }
        expect(response).to have_http_status(422)
      end
    end

    context 'with invalid transaction_amount' do
      it 'returns a 422 error' do
        put :update, params: { id: transaction.to_param, transaction: { transaction_amount: 0 } }
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:transaction) { create(:transaction, user: user) }

    it 'deletes the transaction logically' do
      expect {
        delete :destroy, params: { id: transaction.to_param }
      }.to change { transaction.reload.delete_flag }.from(false).to(true)
    end

    it 'renders a JSON response with the deleted transaction' do
      delete :destroy, params: { id: transaction.to_param }
      expect(response).to have_http_status(200)
      expect(response.content_type).to include('application/json')
    end
  end

  describe 'GET #total_transactions' do
    let(:category1) { create(:category, transaction_type: 'income', user: user, delete_flag: false) }
    let(:category2) { create(:category, transaction_type: 'expense', user: user, delete_flag: false) }

    context 'with transactions present' do
      let!(:transaction1) { create(:transaction, user: user, transaction_amount: 100, category: category1) }
      let!(:transaction2) { create(:transaction, user: user, transaction_amount: 50, category: category2) }

      it 'returns total income and expense for given date range' do
        get :total_transactions, params: { start_date: 1.week.ago.to_date, end_date: Date.today }
        expect(response).to have_http_status(200)
        expect(json_response['data']).to include(
          'income' => hash_including('total' => 100),
          'expense' => hash_including('total' => 50)
        )
      end

      it 'filters by category_id if provided' do
        get :total_transactions, params: { start_date: 1.week.ago.to_date, end_date: Date.today, category_id: category1.id }
        expect(response).to have_http_status(200)
        expect(json_response['data']).to include(
          'income' => hash_including('total' => 100)
        )
      end

      it 'returns 404 if no transactions found' do
        get :total_transactions, params: { start_date: 1.year.ago.to_date, end_date: 11.months.ago.to_date }
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'GET #category_transactions' do
    let(:category) { create(:category, user: user, delete_flag: false) }

    context 'with transactions present' do
      let!(:transaction1) { create(:transaction, user: user, category: category) }
      let!(:transaction2) { create(:transaction, user: user, category: category) }

      it 'returns transactions for a specific category' do
        get :category_transactions, params: { category_id: category.id }
        expect(response).to have_http_status(200)
        expect(json_response['data'].length).to eq(2)
      end
    end

    context 'without transactions' do
      it 'returns 404 if no transactions found' do
        get :category_transactions, params: { category_id: category.id, start_date: 1.year.ago.to_date, end_date: 11.months.ago.to_date }
        expect(response).to have_http_status(404)
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
