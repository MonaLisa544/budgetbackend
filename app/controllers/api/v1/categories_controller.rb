class Api::V1::CategoriesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_category, only: [:show, :update, :destroy]

    def index
      begin
        @categories = Category.where(user_id: current_user.id, delete_flag: false)
    
        type = params[:transaction_type] # <-- энэ шүүлтийг зөв болго
        @categories = @categories.where(transaction_type: type) if type.present?
    
        if @categories.present?
          render json: CategorySerializer.new(@categories).serialized_json
        else
          raise ActiveRecord::RecordNotFound, 'Category not found'
        end
      rescue ActiveRecord::RecordNotFound => exception
        render json: { errors: { name: [exception.message] }}, status: :not_found
      end
    end

    def show
        render json: CategorySerializer.new(@category).serialized_json
    end

    def create
        begin
          @category = current_user.categories.build(category_params)
          @category.save!
          render json: CategorySerializer.new(@category).serialized_json, status: :created
        rescue ActionController::ParameterMissing => e
          render json: { error: e.message }, status: :unprocessable_entity
        rescue ActiveRecord::RecordInvalid => e
          if e.record.errors[:category_name].include?("has already been taken")
            render json: { errors: { category_name: ["has already been taken under these conditions"] } }, status: :unprocessable_entity
          else
            render json: { errors: e.record.errors }, status: :unprocessable_entity
          end
        end
      end

      def update
        if @category.update(category_params)
          render json: CategorySerializer.new(@category).serialized_json, status: :ok
        else
          render json: { errors: @category.errors }, status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue ActiveRecord::RecordInvalid => e
        handle_record_invalid(e)
      end

    def destroy
        transactions = @category.transactions

        category_other = Category.find_by(category_name: 'Other', user_id: current_user.id, transaction_type: @category.transaction_type)

        if category_other.nil?
            category_other = Category.new(category_name: 'Other', user_id: current_user.id, transaction_type: @category.transaction_type, icon: 'circleOff')
            category_other.save!
        end

        transactions.update_all(category_id: category_other.id)
        @category.update(delete_flag: true)

        render json: CategorySerializer.new(@category).serialized_json
    end

    private
        def category_params
            params.require(:category).permit(:category_name, :icon, :icon_color, :transaction_type)
        end
        def set_category
          begin
            # Adjust the query to match your database schema and associations
            @category = Category.find_by(user_id: current_user.id, id: params[:id], delete_flag: false)

            unless @category
              raise ActiveRecord::RecordNotFound, 'Category not found'
            end
          rescue ActiveRecord::RecordNotFound => exception
            render json: { errors: { name: [exception.message] }}, status: :not_found
          end
        end
end
