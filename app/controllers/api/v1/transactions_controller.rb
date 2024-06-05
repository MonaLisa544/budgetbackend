
class Api::V1::TransactionsController < ApplicationController
    def index
        @transactions = Transaction.all
        render json: TransactionSerializer.new(@transactions).serialized_json
    end

    def show 
        @transaction = Transaction.find(params[:id])
        render json: @transaction
    end

    def new
        @transaction = Transaction.new
        render json: TransactionSerializer.new(@transaction).serialized_json
    end
    
    def create
        @transaction = Transaction.new(transaction_params)
    
        if @transaction.save
            render json: TransactionSerializer.new(@transaction).serialized_json, status: 200
        else
            render json: { errors: @transaction.errors }, status: 422 # unprocessable_entity
        end
    end
    
    def update
        @transaction = Transaction.find(params[:id])
    
        if @transaction.update(transaction_params)
            render json: TransactionSerializer.new(@transaction).serialized_json, status: 200
        else
            render json: { errors: @transaction.errors }, status: 422
        end
    end
    
    def destroy
        @transaction = Transaction.find(params[:id])
        @transaction.destroy
    
        render json: TransactionSerializer.new(@transaction).serialized_json
    end

    private
        def transaction_params
            params.require(:transaction).permit(:transaction_amount, :transaction_date, :transaction_type, :description, :frequency, :category_id )
        end

end
