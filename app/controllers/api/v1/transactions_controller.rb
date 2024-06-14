class Api::V1::TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_transaction, only: [:show, :update, :destroy]

  PER_PAGE = 10

  def index
    transactions = Transaction.where(user_id: current_user.id, delete_flag: false)
    render_not_found if transactions.empty?

    filtered_transactions = transactions.where(transaction_date: date_range)
                                         .paginate(page: page, per_page: per_page)
    render json: TransactionSerializer.new(filtered_transactions).serialized_json
  end

  def show
    render json: TransactionSerializer.new(@transaction).serialized_json
  end

  def create
    transaction_attributes = transaction_params.except(:category_name)
    category_name = transaction_params[:category_name]

    if category_name.present?
      category = Category.find_by(name: category_name)
      if category.nil?
        category = Category.create(name: category_name)
      end
      transaction_attributes[:category_id] = category.id
    end

    @transaction = current_user.transactions.build(transaction_attributes)

    if @transaction.save
      render json: TransactionSerializer.new(@transaction).serialized_json, status: 201
    else
      render json: { errors: @transaction.errors }, status: 422
    end
  end

  def update
    transaction_attributes = transaction_params.except(:category_name)
    category_name = transaction_params[:category_name]

    if category_name.present?
      category = Category.find_by(name: category_name)
      if category.nil?
        category = Category.create(name: category_name)
      end
      transaction_attributes[:category_id] = category.id
    end

    if @transaction.update(transaction_attributes)
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
    transactions = Transaction.where(user_id: current_user.id, delete_flag: false)
    render_not_found if transactions.empty?

    type = params[:type]
    category_id = params[:category_id]

    filtered_transactions = transactions.left_joins(:category)
                                .select('categories.transaction_type, categories.id as category_id, categories.name, SUM(transaction_amount) AS total_amount')
                                .where(transaction_date: date_range)
                                .group('categories.transaction_type', 'categories.id', 'categories.name')

    filtered_transactions = filtered_transactions.where(categories: { transaction_type: type }) if type.present?
    filtered_transactions = filtered_transactions.where(category_id: category_id) if category_id.present?

    paginated_transactions = filtered_transactions.paginate(page: page, per_page: per_page)

    total_income = filtered_transactions.to_a.select { |t| t.transaction_type == 'income' }.sum(&:total_amount)
    total_expense = filtered_transactions.to_a.select { |t| t.transaction_type == 'expense' }.sum(&:total_amount)

    formatted_data = paginated_transactions.group_by(&:transaction_type).transform_values do |type_transactions|
      total = type_transactions.first.transaction_type == 'income' ? total_income : total_expense
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
    transactions = Transaction.where(user_id: current_user.id, delete_flag: false)
    render_not_found if transactions.empty?

    category_id = params[:category_id]

    filtered_transactions = transactions.where(transaction_date: date_range, category_id: category_id)
                                .paginate(page: page, per_page: per_page)
    render json: TransactionSerializer.new(filtered_transactions).serialized_json, status: 200
  end

  private

  def transaction_params
    params.require(:transaction).permit(:transaction_name, :transaction_amount, :transaction_date, :description, :frequency, :category_name)
  end

  def set_transaction
    @transaction = Transaction.where(user_id: current_user.id, id: params[:id], delete_flag: false).first
    render_not_found if @transaction.nil?
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
