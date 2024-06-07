class Api::V1::TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: [:show, :update, :destroy]
  before_action :set_transactions, only: [:index]

  def index
    render json: TransactionSerializer.new(@transactions).serialized_json
  end

  def show
    render json: TransactionSerializer.new(@transaction).serialized_json
  end

  def create
    @transaction = current_user.transactions.build(transaction_params)

    if @transaction.save
      render json: TransactionSerializer.new(@transaction).serialized_json, status: 201
    else
      render json: { errors: @transaction.errors }, status: 422
    end
  end

  def update
    if @transaction.update(transaction_params)
      render json: TransactionSerializer.new(@transaction).serialized_json, status: 200
    else
      render json: { errors: @transaction.errors }, status: 422
    end
  end

  def destroy
    @transaction.update(delete_flag: true)
    render json: TransactionSerializer.new(@transaction).serialized_json, status: 200
  end

  private

  def transaction_params
    params.require(:transaction).permit(:transaction_name, :transaction_amount, :transaction_date, :transaction_type, :description, :frequency, :category_id)
  end

  def set_transaction
    log_current_user
    @transaction = Transaction.find_by(user_id: current_user.id, id: params[:id], delete_flag: false)
    render_not_found if @transaction.nil?
  end

  def set_transactions
    log_current_user
    @transactions = Transaction.where(user_id: current_user.id, delete_flag: false)
    render_not_found if @transactions.empty?
  end

  def render_not_found
    render json: { error: 'Transaction not found' }, status: 404
  end

  def log_current_user
    puts "Current User: #{current_user.inspect}"
  end
end
