class Api::V1::TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: [:show, :update, :destroy]
  before_action :set_transactions, only: [:index, :total_transactions, :category_transactions]

  PER_PAGE = 10

  def index
    transactions = @transactions.where(transaction_date: date_range)
                                .paginate(page: page, per_page: per_page)
    render json: TransactionSerializer.new(transactions).serialized_json
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
    type = params[:type]
    category_id = params[:category_id]

    transactions = @transactions.left_joins(:category)
                                .select('categories.transaction_type, categories.id as category_id, categories.name, SUM(transaction_amount) AS total_amount')
                                .where(transaction_date: date_range)
                                .group('categories.transaction_type', 'categories.id', 'categories.name')

    transactions = transactions.where(categories: { transaction_type: type }) if type.present?
    transactions = transactions.where(category_id: category_id) if category_id.present?

    paginated_transactions = transactions.paginate(page: page, per_page: per_page)

    total_income = transactions.to_a.select { |t| t.transaction_type == 'income' }.sum(&:total_amount)
    total_expense = transactions.to_a.select { |t| t.transaction_type == 'expense' }.sum(&:total_amount)

    formatted_data = paginated_transactions.group_by(&:transaction_type).transform_values do |type_transactions|
      total = type_transactions.first.transaction_type == 'in' ? total_income : total_expense
      categories = type_transactions.map { |transaction|
                                            { "id" => transaction.category_id,
                                              "name" => transaction.name,
                                              "amount" => transaction.total_amount }
                                         }
      { total: total, categories: categories }
    end

    render json: { data: formatted_data }, status: 200
  end


  # get only selected category's transactions
  def category_transactions
    category_id = params[:category_id]

    transactions = @transactions.where(transaction_date: date_range, category_id: category_id)
                                .paginate(page: page, per_page: per_page)
    render json: TransactionSerializer.new(transactions).serialized_json, status: 200
  end

  private
  def transaction_params
    params.require(:transaction).permit(:transaction_name, :transaction_amount, :transaction_date,  :description, :frequency, :category_id)
  end

  def set_transaction
    @transaction = Transaction.find_by(user_id: current_user.id, id: params[:id], delete_flag: false)
    render_not_found if @transaction.nil?
  end

  def set_transactions
    @transactions = Transaction.where(user_id: current_user.id, delete_flag: false)
    render_not_found if @transactions.empty?
  end

  def render_not_found
    render json: { error: 'Transaction not found' }, status: 404
  end

  def per_page
    params[:per_page]&.to_i || PER_PAGE
  end

  def page
    params[:page]&.to_i
  end

  def date_range
    params[:start_date]..params[:end_date]
  end
end
