module TransactionsHelper
  PER_PAGE = 10

  def build_transaction_attributes
    transaction_attributes = transaction_params.except(:category_name, :transaction_type)
    category_name = transaction_params[:category_name]
    type = transaction_params[:transaction_type]

    if category_name.present?
      category = Category.find_by(name: category_name, transaction_type: type, delete_flag: false)
      raise ActiveRecord::RecordNotFound, "Category not found" unless category
      transaction_attributes[:category_id] = category.id
    end

    transaction_attributes
  end

  def filter_transactions
    transactions = Transaction.where(user_id: current_user.id, delete_flag: false)
    render_not_found if transactions.empty?

    transactions.where(transaction_date: date_range)
               .paginate(page: page, per_page: per_page)
  end

  def aggregate_transactions(transactions, type = nil, category_id = nil)
    filtered_transactions = transactions.left_joins(:category)
                                        .select('categories.transaction_type, categories.id as category_id, categories.name, categories.icon, SUM(transaction_amount) AS total_amount')
                                        .where(transaction_date: date_range, 'categories.delete_flag': false)
                                        .group('categories.transaction_type', 'categories.id', 'categories.name')

    filtered_transactions = filtered_transactions.where(categories: { transaction_type: type }) if type.present?
    filtered_transactions = filtered_transactions.where(categories: { id: category_id }) if category_id.present?

    total_income = filtered_transactions.select { |t| t.transaction_type == 'income' }.sum(&:total_amount)
    total_expense = filtered_transactions.select { |t| t.transaction_type == 'expense' }.sum(&:total_amount)

    formatted_data = filtered_transactions.group_by(&:transaction_type).transform_values do |type_transactions|
      total = type_transactions.first.transaction_type == 'income' ? total_income : total_expense
      categories = type_transactions.map { |transaction|
        { "id" => transaction.category_id,
          "name" => transaction.name,
          "amount" => transaction.total_amount,
          "icon" => transaction.icon }
      }
      { total: total, categories: categories }
    end

    formatted_data
  end

  def fetch_transactions
    transactions = Transaction.where(user_id: current_user.id, delete_flag: false)
    render_not_found if transactions.empty?
    transactions
  end

  def save_transaction(transaction)
    handle_transaction_operation(transaction) do
      transaction.save!
      TransactionSerializer.new(transaction).serialized_json
    end
  end

  def update_transaction(transaction)
    attributes = build_transaction_attributes
    handle_transaction_operation(transaction) do
      transaction.update!(attributes)
      TransactionSerializer.new(transaction).serialized_json
    end
  end

  def handle_transaction_operation(transaction)
    result = yield

    Transaction.transaction { render json: result, status: 200 }

  # handling errors
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: format_errors(e.record.errors) }, status: 422
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: { category: e.message } }, status: 404
  rescue => e
      render json: { error: e.message }, status: 400
  end

  def format_errors(errors)
    errors.messages.transform_keys(&:to_s).transform_values { |msgs| msgs.join(', ') }
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
