module TransactionsHelper
  PER_PAGE = 10

  # Combined create, update, delete actions with error handling
  def process_transaction(transaction, action)
    Transaction.transaction do
      case action
      when 'create'
        attributes = build_transaction_attributes
        transaction = current_user.transactions.build(attributes)
        transaction.save!
      when 'update'
        attributes = build_transaction_attributes
        transaction.update!(attributes)
      when 'destroy'
        transaction.update!(delete_flag: true)
      end
    end
    render json: TransactionSerializer.new(transaction).serialized_json
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: format_errors(e.record.errors) }, status: 422
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: 404
  rescue => e
    render json: { error: e.message }, status: 400
  end

  # When creating/updating transaction check if given category exists
  def build_transaction_attributes
    transaction_attributes = transaction_params.except(:category_name, :transaction_type)
    category_name = transaction_params[:category_name]
    type = transaction_params[:transaction_type]

    if category_name.present?
      category = Category.find_by(name: category_name, transaction_type: type, delete_flag: false)
      transaction_attributes[:category_id] = category.id if category.present?
    end

    transaction_attributes
  end

  def aggregate_transactions
    # get all categories with it's sum of transaction_amount
    categories = Category.left_joins(:transactions)
                         .select('categories.id, categories.name, COALESCE(SUM(transactions.transaction_amount), 0) as amount, categories.icon, categories.transaction_type')
                         .group('categories.id, transaction_type')
                         .where(user_id: current_user.id, delete_flag: false)
                         .where('transactions.delete_flag = false OR transactions.id IS NULL')

    categories = categories.where(id: params[:category_id]) if params[:category_id].present?
    categories = categories.where(transaction_type: params[:type]) if params[:type].present?
    categories = categories.where(transactions: {transaction_date: params[:start_date]..params[:end_date]}) if params[:start_date].present? || params[:end_date].present?

    formatted_data = categories.group_by(&:transaction_type).transform_values do |categories|
      {
        total: categories.sum(&:amount),
        categories: categories.map { |category| category.attributes.except('transaction_type') }
      }
    end
    formatted_data
  end

  def format_errors(errors)
    errors.messages.transform_keys(&:to_s).transform_values { |msgs| msgs.join(', ') }
  end

  def page
    params[:page]&.to_i
  end

  def per_page
    params[:per_page]&.to_i || TransactionsHelper::PER_PAGE
  end

  def transaction_params
    params.require(:transaction).permit(:transaction_name, :transaction_amount, :transaction_date, :description, :frequency, :category_name, :transaction_type)
  end
end
