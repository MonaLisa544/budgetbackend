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

            private
                def transaction_params
                params.require(:transaction).permit(:transaction_amount, :transaction_date, :transaction_type, :description, :frequency, :delete_flag)
                end

        end
    end
end
