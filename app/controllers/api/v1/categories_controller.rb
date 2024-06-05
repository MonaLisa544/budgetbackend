class Api::V1::CategoriesController < ApplicationController
    def index
        @categories = Category.all
        render json: CategorySerializer.new(@categories).serialized_json
    end 

    def show
        @category = Category.find(params[:id])
        render json: CategorySerializer.new(@category).serialized_json
    end

    def new
        @category = Category.new
        render json: CategorySerializer.new(@category).serialized_json
    end 

    def create
        @category = Category.new(category_params)
        if @category.save
            render json: CategorySerializer.new(@category).serialized_json, status: 200
        else 
            render json: { errors: @category.errors }, status: 422
        end
    end

    def edit 
        @category = Category.find(params[:id])
        render json: @category
    end

    def update 
        @category = Category.find(params[:id])
        if @category.update(category_params)
            render json: CategorySerializer.new(@category).serialized_json, status: 200
        else
            render json: { errors: @category.errors }, status: 422
        end
    end

    def destroy
        @category = Category.find(params[:id])
        @category.destroy

        render json: CategorySerializer.new(@category).serialized_json
    end

    private
    
        def category_params
            params.require(:category).permit(:name, :delete_flag)
        end
end
            