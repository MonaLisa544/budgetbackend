class Api::V1::TransactionsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_transaction, only: [:show, :update, :destroy]

    def index
         transactions = Transaction.where(delete_flag: false)
        render json: TransactionSerializer.new( transactions).serialized_json
    end

    def show 
        render json: TransactionSerializer.new( transaction).serialized_json
    end
    
    def create
         transaction = Transaction.new(transaction_params)
    
        if  transaction.save
            render json: TransactionSerializer.new( transaction).serialized_json, status: 201
        else
            render json: { errors:  transaction.errors }, status: 422
        end
    end
    
    def update
        if  transaction.update(transaction_params)
            render json: TransactionSerializer.new( transaction).serialized_json, status: 200
        else
            render json: { errors:  transaction.errors }, status: 422
        end
    end
    
    def destroy
         transaction.update(delete_flag: true)
        render json: TransactionSerializer.new( transaction).serialized_json, status: 200
    end

    private

    def transaction_params
        params.require(:transaction).permit(:transaction_amount, :transaction_date, :transaction_type, :description, :frequency, :category_id)
    end

    def set_transaction
         transaction = Transaction.find_by(id: params[:id], delete_flag: false)
        unless  transaction
            render json: { error: 'Transaction not found' }, status: 404
        end
    end
end
