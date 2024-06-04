module Api
    module V1
        class TransactionsController < ApplicationController
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
                    render json: TransactionSerializer.new(@transaction).serialized_json, status: :created
                else
                    render json: { errors: @transaction.errors }, status: :unprocessable_entity
                end
            end
            
            def update
                @transaction = Transaction.find(params[:id])
            
                if @transaction.update(transaction_params)
                    render json: TransactionSerializer.new(@transaction).serialized_json, status: :ok
                else
                    render json: { errors: @transaction.errors }, status: :unprocessable_entity
                end
            end
            
            def destroy
                @transaction = Transaction.find(params[:id])
                @transaction.destroy
            
                redirect_to root_path, status: :see_other
                render json: TransactionSerializer.new(@transaction).serialized_json
            end

            private
                def transaction_params
                params.require(:transaction).permit(:transaction_amount, :transaction_date, :transaction_type, :description, :frequency, :delete_flag)
                end

        end
    end
end
