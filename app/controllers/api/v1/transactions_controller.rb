class Api::V1::TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: [:show, :update, :destroy]

  include TransactionsHelper

  def index
    transactions = filter_transactions
    render json: TransactionSerializer.new(transactions).serialized_json, status: 200
  end

  def show
    render json: TransactionSerializer.new(@transaction).serialized_json
  end

  def create

    save_transaction(@transaction)
  end

  def update
    update_transaction(@transaction)
  end

  def destroy
    Transaction.transaction do
      @transaction.update!(delete_flag: true)
      render json: TransactionSerializer.new(@transaction).serialized_json, status: 200
    end
  rescue ActiveRecord::RecordInvalid => e
    render_error(e.record.errors.full_messages, 422)
  rescue => e
    render_error(e.message, 400)
  end

  def total_transactions
    transactions = fetch_transactions
    type = params[:type]
    category_id = params[:category_id]

    formatted_data = aggregate_transactions(transactions, type, category_id)
    render json: { data: formatted_data }, status: 200
  end

  def category_transactions
    transactions = fetch_transactions
    category_id = params[:category_id]

    filtered_transactions = filter_transactions_by_category(transactions, category_id)
    render json: TransactionSerializer.new(filtered_transactions).serialized_json, status: 200
  rescue => e
    render_error(e.message, 500)
  end

  private

  def transaction_params
    params.require(:transaction).permit(:transaction_name, :transaction_amount, :transaction_date, :description, :frequency, :category_name, :transaction_type)
  end

  def set_transaction
    @transaction = Transaction.find_by(id: params[:id], user_id: current_user.id, delete_flag: false)
    render_not_found if @transaction.nil?
  end

end
