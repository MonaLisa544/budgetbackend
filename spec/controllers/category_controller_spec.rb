# spec/controllers/api/v1/categories_controller_spec.rb
require 'rails_helper'

RSpec.describe Api::V1::CategoriesController, type: :controller do
  let(:user) { create(:user) }
  let(:admin) { create(:user, role: RoleConstants::ADMIN_ROLE) }
  let!(:category) { create(:category, user: user) }
  let!(:admin_category) { create(:category, user: admin) }
  let(:valid_attributes) { { name: "New Category", icon: "new-icon", transaction_type: "expense" } }
  let(:invalid_attributes) { { name: "", icon: "new-icon", transaction_type: "expense" } }

  before do
    sign_in user
  end

  describe "GET #index" do
    it "returns a success response" do
      get :index, params: {}
      expect(response).to be_successful
    end

    it "returns only categories belonging to the current user or admin" do
      get :index, params: {}
      expect(json_response.size).to eq(2)
      expect(json_response.map { |c| c['id'] }).to include(category.id, admin_category.id)
    end

    it "filters categories by transaction_type if provided" do
      get :index, params: { type: "expense" }
      expect(json_response.size).to eq(2)
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { id: category.id }
      expect(response).to be_successful
    end

    it "returns not found if the category does not belong to the user" do
      get :show, params: { id: admin_category.id }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Category" do
        expect {
          post :create, params: { category: valid_attributes }
        }.to change(Category, :count).by(1)
      end

      it "renders a JSON response with the new category" do
        post :create, params: { category: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(response.content_type).to include("application/json")
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new category" do
        post :create, params: { category: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to include("application/json")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: "Updated Category" } }

      it "updates the requested category" do
        put :update, params: { id: category.id, category: new_attributes }
        category.reload
        expect(category.name).to eq("Updated Category")
      end

      it "renders a JSON response with the category" do
        put :update, params: { id: category.id, category: valid_attributes }
        expect(response).to be_successful
        expect(response.content_type).to include("application/json")
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the category" do
        put :update, params: { id: category.id, category: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to include("application/json")
      end
    end
  end

  describe "DELETE #destroy" do
    it "sets delete_flag to true for the requested category" do
      delete :destroy, params: { id: category.id }
      category.reload
      expect(category.delete_flag).to be_truthy
    end

    it "transfers transactions to 'Other' category" do
      other_category = create(:category, name: 'Other', user: user, transaction_type: category.transaction_type)
      create(:transaction, category: category, user: user)
      delete :destroy, params: { id: category.id }
      expect(Transaction.where(category: category).count).to eq(0)
      expect(Transaction.where(category: other_category).count).to eq(1)
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
