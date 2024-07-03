module TransactionsHelper
  PER_PAGE = 10

  # Combined create, update, delete actions with error handling
  def process_transaction(transaction, action)
    Transaction.transaction do
      case action
      when 'create'
        attributes = build_transaction_attributes
        transaction = current_user.transactions.build(attributes)
        if transaction.frequency
          transaction.create_recurring
        else
          transaction.save!
        end
      when 'update'
        attributes = build_transaction_attributes
        transaction.update!(attributes)
        if !transaction.frequency
          transaction.delete_associated_recurring_transactions
        end
      when 'destroy'
        if transaction.frequency
          transaction.delete_associated_recurring_transactions
        end
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
      category = Category.find_by(user_id: current_user.id, name: category_name, transaction_type: type, delete_flag: false)
      transaction_attributes[:category_id] = category.id if category.present?
    end

    transaction_attributes
  end

  def aggregate_transactions
    # get all the categories
    categories = Category.select(:id, :name, :transaction_type, :icon)
                         .where(delete_flag: false, user_id: current_user.id)
                         .tap do |c|
                           c.where!(id: params[:category_id]) if params[:category_id].present?
                           c.where!(transaction_type: params[:type]) if params[:type].present?
                         end
    # get all the transactions and filter them
    filtered_transactions = Transaction.where(delete_flag: false)
    if params[:start_date].present? || params[:end_date].present?
      filtered_transactions = filtered_transactions.where(transaction_date: params[:start_date]..params[:ends_date])
    end

    # join transactions,category and format each category
    formatted_data = categories.map do |category|
      category_transactions = filtered_transactions.where(category_id: category.id)
      {
        id: category.id,
        name: category.name,
        icon: category.icon,
        transaction_type: category.transaction_type,
        amount: category_transactions.sum('transaction_amount') || 0,
        transactions_count: category_transactions.count || 0
      }
    end

    formatted_data.group_by { |data| data[:transaction_type] }
                  .transform_values do |categories|
      {
        total: categories.sum { |category| category[:amount] },
        categories: categories.map { |category| category.except(:transaction_type) }
      }
    end
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
