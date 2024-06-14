class Api::V1::CategoriesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_category, only: [:show, :update, :destroy]

    def index
        @categories = Category.where("categories.user_id = ? OR EXISTS (SELECT 1 FROM users WHERE users.id = categories.user_id AND users.role = ?)", current_user.id, 2).where(delete_flag: false)
        
        if @categories.empty?
          render json: { error: "Categories not found" }, status: 404
          return
        end
        
        type = params[:type]
        categories = @categories.where(transaction_type: type) if type.present?
        
        render json: (categories || @categories)
    end

    def show
        render json: CategorySerializer.new(@category).serialized_json
    end

    # create category
    def create
        @category = current_user.categories.build(category_params)
        if @category.save
            render json: CategorySerializer.new(@category).serialized_json, status: 200
        else
            render json: { errors: @category.errors }, status: 422
        end
    end

    def update
        if @category.update(category_params)
            render json: CategorySerializer.new(@category).serialized_json, status: 200
        else
            render json: { errors: @category.errors }, status: 422
        end
    end

    def destroy
        @category.update(delete_flag: true)
        render json: CategorySerializer.new(@category).serialized_json
    end

    private
        def category_params
            params.require(:category).permit(:name, :icon, :transaction_type)
        end

        def set_category
            @category = Category.where(user_id: current_user.id, id: params[:id], delete_flag: false)
            if @category.empty?
                render json: { error: "Category not found" }, status: :not_found
            end
        end
end