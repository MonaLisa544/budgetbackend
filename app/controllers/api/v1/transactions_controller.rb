class Api::V1::TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: [:show, :update, :destroy]
  before_action :set_transactions, only: [:index, :total_transactions, :category_transactions]

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

  # get all transactions grouped by transaction type & category
  def total_transactions
    start_date = params[:start_date]
    end_date = params[:end_date]
    type = params[:type]

    @transactions = Transaction.left_joins(:category)
                              .select('categories.transaction_type, categories.id as category_id, categories.name, SUM(transaction_amount) AS total_amount')
                              .where(transaction_date: start_date..end_date)

    if type.present?
      @transactions = @transactions.where(categories: { transaction_type: type })
    end

    @transactions = @transactions.group(:transaction_type, :category_id)

    formatted_data = @transactions.group_by(&:transaction_type).transform_values do |type_transactions|
      total = type_transactions.sum(&:total_amount)
      categories = type_transactions.map { |transaction| { "id" => transaction.category_id, "name" => transaction.name, "amount" => transaction.total_amount } }
      { "total" => total, "categories" => categories }
    end

    render json: { data: formatted_data }, status: 200
  end

  # get only selected category's transactions
  def category_transactions
    start_date = params[:start_date]
    end_date = params[:end_date]
    category_id = params[:category_id]

    @transactions = Transaction.where(transaction_date: start_date..end_date, category_id: category_id)
    render json: TransactionSerializer.new(@transactions).serialized_json, status: 200
  end



  private
  def transaction_params
    params.require(:transaction).permit(:transaction_name, :transaction_amount, :transaction_date,  :description, :frequency, :category_id)
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